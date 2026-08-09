# Android CI — release to Play on every push

A push to `main` builds the app and uploads it to the Play **internal** track. No
person runs anything. This mirrors what Xcode Cloud does for iOS, and it exists
because the Android half used to wait on someone with the right files on their disk.

Set up on 2026-08-09 across HPC, Bakedown, SuppConnect, CubCampus and Vault Messages.
Everything below was learned from those five, in one afternoon, mostly the hard way.

## The two moving parts

| Part | Where |
|---|---|
| The workflow | `.github/workflows/release-android.yml` |
| The lane it calls | `deploy` in `android/fastlane/Fastfile`, via `internal` |

The same `deploy` lane runs by hand and under CI. It takes the Play key from
`PLAY_JSON_KEY_PATH` when that is set and from the `Appfile` when it is not, and it
resolves every path from wherever `pubspec.yaml` actually is. Do not add a
CI-only lane; keeping one lane means CI cannot drift away from what you test locally.

## Setting up a new app

```bash
bash scripts/bootstrap_ci_secrets.sh     # from the repo root, on a machine that can already release
```

It reads the gitignored files you already have and writes them as repository
secrets. Then push, or `gh workflow run release-android.yml`.

Two things to check yourself:

1. **Pin the Flutter version** in the workflow's `Install Flutter` step to the
   version this app builds with. The default is what the other apps use.
2. **Prove the Play key reaches this package** before trusting a build. A new app
   is not automatically covered by the shared service account — Vault Messages
   needed its own, and the shared key answers 403 for it. A key that cannot reach
   the package wastes a full build before it says so.

## The runners

Builds run on `chonky`, on runners registered at the **Sapid-Labs org** level, so
every repo in the org sees them with no per-repo registration. Labels:
`self-hosted, chonky, android`. There are two, so two apps can build at once.

Why self-hosted: a build that took **785 seconds** on a GitHub-hosted runner took
**122 seconds** on chonky, because Gradle and pub caches survive between runs. It
also costs no Actions minutes.

Two things the host needs, both one-time and already done:

- `/opt/hostedtoolcache` must exist and be owned by the runner user. `setup-ruby`
  hardcodes that path and cannot be pointed elsewhere; without it the job dies in
  ten seconds with `EACCES`.
- Gradle is capped in each runner's `.env` (`org.gradle.workers.max=8`, 6 GB heap).
  Uncapped, it takes all 32 threads and starves everything else on the machine.

An app **outside** the Sapid-Labs org should use `runs-on: ubuntu-latest` instead.
That is a deliberate choice for client repos: their builds should not quietly move
onto a personal server.

## The versionCode, and the one failure mode left

`android/fastlane/metadata/versionCode` is the source of the next number. The lane
bumps it, the build uses it, and the workflow commits the new value back.

Two failures come from that file, and it is worth knowing which is which:

- **The push is rejected** because `main` moved during the build. Common — a build
  takes minutes. Handled: the step rebases and retries three times. It is not a
  failed release; the AAB is already on Play.
- **The job is killed between the upload and the commit** (cancelled, timed out).
  Not handled. The file stays behind, the next run reuses a code Play has already
  seen, and the upload is refused with `Version code N has already been used`.

The cure for the second is to read Play's highest existing versionCode and build
from that, instead of trusting the file. Until that exists, fix it by hand: read
the track, set the file to match, commit.

```bash
python3 ~/projects/fun-money/loop/play_tracks.py tracks <package>   # what Play holds
```

## What is deliberately not here

**Shorebird.** `shorebird release` needs a CI token that only the interactive
`shorebird login:ci` can mint. The apps that use Shorebird build without it in CI,
by Joe's decision on 2026-08-09, which means a CI build cannot take an OTA patch.
Hand-run lanes still make patchable releases. If you add a Shorebird step here,
add the token first and say so in this file.

**Production.** CI only ever writes to the internal track. Promoting to production
is a decision, not a build step.
