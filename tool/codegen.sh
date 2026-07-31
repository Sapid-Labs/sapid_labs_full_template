#!/usr/bin/env bash
# Code generation for the Sapid Labs Flutter template. Use this, not `build_runner` directly.
#
# Two things are wrong with the plain command, and both are silent:
#
#   1. `dart run build_runner build` compiles the build script AOT, and
#      `dart compile` refuses a package graph that contains a build hook.
#      path_provider_foundation -> objective_c ships hook/build.dart, so the
#      run dies with "'dart compile' does not support build hooks" before a
#      single builder starts. build_runner only falls back to JIT for
#      dart:mirrors failures, so it cannot recover from this one by itself.
#      --force-jit skips the AOT attempt.
#
#   2. --delete-conflicting-outputs deletes the .g.dart files first. If a
#      builder then fails, the files stay deleted and the analyzer reports
#      dozens of errors that look unrelated. Recover with `git checkout --`.
#      Do not add that flag here.
#
set -euo pipefail
cd "$(dirname "$0")/.."
exec dart run build_runner build --force-jit "$@"
