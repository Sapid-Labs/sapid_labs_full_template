#!/usr/bin/env python3
"""Pick one provider per category and delete the rest.

    ./tool/stack.py --backend supabase --analytics none --crash sentry

The template ships every provider it supports, because a template that only has
the one you picked is not a template. A child app wants the opposite: one file
per job, one SDK per job, and nothing in the merged Android manifest it cannot
explain to Play. This script is the one-way trip between those two states, run
once just after scaffolding.

What it does, in order:

  1. deletes the provider files you did not pick, and their `stack/*.md` guides
  2. activates the chosen provider's `@Injectable(as: Interface)` annotation and
     leaves a plain `@Injectable()` on anything it kept but did not choose
  3. toggles the `// STACK_<NAME>:BEGIN … :END` blocks in lib/main.dart
  4. drops the now-unused dependencies from pubspec.yaml
  5. rewrites assets/config.example.json to the keys the survivors read

It does NOT run codegen or pub get -- it prints those as the next steps, so you
can read the diff before anything regenerates on top of it.

Every choice is per category and independent: `--backend supabase` with
`--crash firebase` is a supported combination and keeps firebase_core for the
one that needs it. Dependencies are removed by set difference over what the
survivors declare, never by name-matching 'firebase'.

Written for python3 with no third-party packages, because the only thing a
fresh Flutter checkout is guaranteed to have is the interpreter macOS ships.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


class Provider:
    """One vendor's answer to one category.

    files    dart files nothing else may import once this provider is dropped
    deps     pubspec entries it needs; shared entries appear on several providers
    guide    its stack/*.md activation note
    marker   the STACK_<NAME> token used in pubspec comments and main.dart blocks
    iface    the annotation to activate, as (file, interface)
    config   assets/config.json keys it reads
    """

    def __init__(self, key, label, marker, files, deps, guide, iface, config):
        self.key = key
        self.label = label
        self.marker = marker
        self.files = files
        self.deps = deps
        self.guide = guide
        self.iface = iface
        self.config = config


AUTH = 'lib/features/auth/services/'
FEED = 'lib/features/feedback/services/'
ANLY = 'lib/features/analytics/services/'
CRSH = 'lib/features/shared/services/crash/'

CATEGORIES = {
    'backend': [
        Provider(
            'firebase', 'Firebase (Auth + Firestore)', 'STACK_FIREBASE',
            files=[AUTH + 'firebase_auth_service.dart',
                   FEED + 'firebase_feedback_service.dart',
                   'lib/app/firebase_options.dart'],
            deps=['firebase_core', 'firebase_auth', 'cloud_firestore'],
            guide='stack/FIREBASE.md',
            iface=[(AUTH + 'firebase_auth_service.dart', 'AuthService'),
                   (FEED + 'firebase_feedback_service.dart', 'FeedbackService')],
            config=[]),
        Provider(
            'supabase', 'Supabase (Auth + Postgres)', 'STACK_SUPABASE',
            files=[AUTH + 'supabase_auth_service.dart',
                   FEED + 'supabase_feedback_service.dart'],
            deps=['supabase_flutter'],
            guide='stack/SUPABASE.md',
            iface=[(AUTH + 'supabase_auth_service.dart', 'AuthService'),
                   (FEED + 'supabase_feedback_service.dart', 'FeedbackService')],
            config=['SUPABASE_URL', 'SUPABASE_ANON_KEY']),
        Provider(
            'pocketbase', 'Pocketbase', 'STACK_POCKETBASE',
            files=[AUTH + 'pocketbase_auth_service.dart',
                   FEED + 'pocketbase_feedback_service.dart'],
            deps=['pocketbase'],
            guide='stack/POCKETBASE.md',
            iface=[(AUTH + 'pocketbase_auth_service.dart', 'AuthService'),
                   (FEED + 'pocketbase_feedback_service.dart', 'FeedbackService')],
            config=['POCKETBASE_URL']),
    ],
    'analytics': [
        Provider(
            'firebase', 'Firebase Analytics', 'STACK_FIREBASE_ANALYTICS',
            files=[ANLY + 'firebase_analytics_service.dart'],
            deps=['firebase_core', 'firebase_analytics'],
            guide='stack/FIREBASE_ANALYTICS.md',
            iface=[(ANLY + 'firebase_analytics_service.dart', 'AnalyticsService')],
            config=[]),
        Provider(
            'amplitude', 'Amplitude', 'STACK_AMPLITUDE',
            files=[ANLY + 'amplitude_analytics_service.dart'],
            deps=['amplitude_flutter'],
            guide='stack/AMPLITUDE.md',
            iface=[(ANLY + 'amplitude_analytics_service.dart', 'AnalyticsService')],
            config=['AMPLITUDE_API_KEY']),
        Provider(
            'none', 'No analytics (calls go nowhere)', 'STACK_NO_ANALYTICS',
            files=[ANLY + 'noop_analytics_service.dart'],
            deps=[], guide=None,
            iface=[(ANLY + 'noop_analytics_service.dart', 'AnalyticsService')],
            config=[]),
    ],
    'crash': [
        Provider(
            'sentry', 'Sentry', 'STACK_SENTRY',
            files=[CRSH + 'sentry_crash_service.dart'],
            deps=['sentry_flutter'],
            guide='stack/SENTRY.md',
            iface=[(CRSH + 'sentry_crash_service.dart', 'CrashService')],
            config=['SENTRY_DSN']),
        Provider(
            'firebase', 'Firebase Crashlytics', 'STACK_FIREBASE_CRASHLYTICS',
            files=[CRSH + 'firebase_crash_service.dart'],
            deps=['firebase_core', 'firebase_crashlytics'],
            guide='stack/FIREBASE_CRASHLYTICS.md',
            iface=[(CRSH + 'firebase_crash_service.dart', 'CrashService')],
            config=[]),
        Provider(
            'none', 'No crash reporting (debug print only)', 'STACK_NO_CRASH',
            files=[CRSH + 'noop_crash_service.dart'],
            deps=[], guide=None,
            iface=[(CRSH + 'noop_crash_service.dart', 'CrashService')],
            config=[]),
    ],
}

# Read by every app whatever it picks, so it survives any selection.
ALWAYS_CONFIG = ['SERVER_CLIENT_ID', 'GOOGLE_WEB_CLIENT_ID',
                 'REVENUECAT_GOOGLE_API_KEY', 'REVENUECAT_IOS_API_KEY']

ANNOTATION = r'@(Injectable|Singleton|LazySingleton)'


def find(category: str, key: str) -> Provider:
    for provider in CATEGORIES[category]:
        if provider.key == key:
            return provider
    raise SystemExit(f'{category}: no provider called {key!r}')


def activate_annotation(path: Path, interface: str, plan: list) -> None:
    """Uncomment `// @X(as: Interface)` and comment the plain `@X()` below it.

    Two live registrations for one interface compile without complaint and throw
    at startup, which is why this is done by a script and pinned by a test rather
    than left to whoever is reading the guide.
    """
    lines = path.read_text().splitlines()
    out, changed = [], False
    for line in lines:
        stripped = line.strip()
        commented = re.match(r'//\s*(' + ANNOTATION + r'\(\s*as:\s*' +
                             interface + r'\))', stripped)
        if commented:
            out.append(line[:len(line) - len(line.lstrip())] + commented.group(1))
            changed = True
            continue
        plain = re.match(ANNOTATION + r'\(\)\s*$', stripped)
        if plain and changed:
            out.append(line[:len(line) - len(line.lstrip())] + '// ' + stripped)
            continue
        out.append(line)
    if changed:
        plan.append(('annotate', f'{path.relative_to(ROOT)} -> {interface}'))
        path.write_text('\n'.join(out) + '\n')


def toggle_blocks(path: Path, keep: set, plan: list) -> None:
    """Comment or uncomment each `// STACK_<NAME>:BEGIN … :END` block.

    Block toggling rather than annotation swapping, because main.dart's init code
    is statements and not a declaration -- there is nothing to move an `as:` onto.
    A block whose marker is not in `keep` is commented out line by line; one that
    is has its `// ` prefixes stripped. Both directions are idempotent, so running
    the script twice is not a way to lose the file.
    """
    lines = path.read_text().splitlines()
    out, marker, touched = [], None, []
    begin = re.compile(r'^(\s*)//\s*(STACK_\w+):BEGIN\s*$')
    end = re.compile(r'^\s*//\s*STACK_\w+:END\s*$')
    for line in lines:
        opened = begin.match(line)
        if opened:
            marker = opened.group(2)
            out.append(line)
            continue
        if marker and end.match(line):
            marker = None
            out.append(line)
            continue
        if marker is None:
            out.append(line)
            continue
        indent = line[:len(line) - len(line.lstrip())]
        body = line.strip()
        wanted = marker in keep
        if wanted and body.startswith('// '):
            out.append(indent + body[3:])
            touched.append(marker)
        elif wanted and body == '//':
            out.append('')
        elif not wanted and body and not body.startswith('//'):
            out.append(indent + '// ' + body)
            touched.append(marker)
        else:
            out.append(line)
    if touched:
        plan.append(('main.dart', ', '.join(sorted(set(touched)))))
    path.write_text('\n'.join(out) + '\n')


def strip_dependencies(path: Path, drop: set, plan: list) -> None:
    """Remove pubspec lines for dependencies no surviving provider declares."""
    kept, removed = [], []
    for line in path.read_text().splitlines():
        name = re.match(r'\s{2}([a-z_0-9]+):', line)
        if name and name.group(1) in drop:
            removed.append(name.group(1))
            continue
        kept.append(line)
    if removed:
        plan.append(('pubspec.yaml', 'drop ' + ', '.join(sorted(removed))))
    path.write_text('\n'.join(kept) + '\n')


def write_config_example(path: Path, keys: list, plan: list) -> None:
    existing = {}
    if path.exists():
        try:
            existing = json.loads(path.read_text())
        except json.JSONDecodeError:
            existing = {}
    body = {key: existing.get(key, '') for key in keys}
    path.write_text(json.dumps(body, indent=2) + '\n')
    plan.append(('assets/config.example.json', ', '.join(keys)))


def git_is_dirty() -> bool:
    try:
        out = subprocess.run(['git', 'status', '--porcelain'], cwd=ROOT,
                             capture_output=True, text=True, check=True)
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False
    return bool(out.stdout.strip())


def main() -> int:
    parser = argparse.ArgumentParser(
        description='Keep one provider per category and delete the others.')
    for category, providers in CATEGORIES.items():
        parser.add_argument('--' + category, required=True,
                            choices=[p.key for p in providers],
                            help='one of: ' + ', '.join(p.key for p in providers))
    parser.add_argument('--dry-run', action='store_true',
                        help='print the plan and change nothing')
    parser.add_argument('--force', action='store_true',
                        help='run even though the git tree is dirty')
    args = parser.parse_args()

    chosen = {c: find(c, getattr(args, c)) for c in CATEGORIES}

    if not args.dry_run and not args.force and git_is_dirty():
        print('The git tree is dirty. This script deletes files, so commit or '
              'stash first, or pass --force.', file=sys.stderr)
        return 1

    keep_markers = {p.marker for p in chosen.values()}
    keep_deps = {d for p in chosen.values() for d in p.deps}
    all_deps = {d for providers in CATEGORIES.values()
                for p in providers for d in p.deps}
    keep_files = {f for p in chosen.values() for f in p.files}

    doomed_files, doomed_guides = [], []
    for category, providers in CATEGORIES.items():
        for provider in providers:
            if provider is chosen[category]:
                continue
            doomed_files += [f for f in provider.files if f not in keep_files]
            if provider.guide and provider.guide not in {
                    p.guide for p in chosen.values()}:
                doomed_guides.append(provider.guide)

    plan = []
    print('Keeping:')
    for category, provider in chosen.items():
        print(f'  {category:<10} {provider.label}')
    print()

    for relative in sorted(set(doomed_files + doomed_guides)):
        path = ROOT / relative
        if not path.exists():
            continue
        plan.append(('delete', relative))
        if not args.dry_run:
            path.unlink()

    if not args.dry_run:
        for provider in chosen.values():
            for relative, interface in provider.iface:
                path = ROOT / relative
                if path.exists():
                    activate_annotation(path, interface, plan)
        toggle_blocks(ROOT / 'lib/main.dart', keep_markers, plan)
        strip_dependencies(ROOT / 'pubspec.yaml', all_deps - keep_deps, plan)
        config_keys = ALWAYS_CONFIG + [k for p in chosen.values() for k in p.config]
        write_config_example(ROOT / 'assets/config.example.json', config_keys, plan)
        # This script and its guard test describe a template that has every
        # provider. Once one is picked they are both false: the manifest names
        # files that are gone, so the test fails on the first `flutter test` in
        # the new app and reads as a broken checkout rather than as a script that
        # finished its job. It is a one-way trip -- git has the rest.
        for leftover in ('test/stack/stack_manifest_test.dart', 'tool/stack.py'):
            path = ROOT / leftover
            if path.exists():
                path.unlink()
                plan.append(('delete', leftover + '  (its job is done)'))
    else:
        plan.append(('would also', 'flip annotations, main.dart blocks, '
                     'pubspec deps and config.example.json'))

    for kind, detail in plan:
        print(f'  {kind:<28} {detail}')

    print()
    if args.dry_run:
        print('Dry run. Nothing was written.')
        return 0
    print('Next, in this order:')
    print('  flutter pub get')
    print('  ./tool/codegen.sh')
    print('  flutter test')
    print()
    print('Then put the keys from assets/config.example.json into')
    print('assets/config.json, which is gitignored and is where secrets live.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
