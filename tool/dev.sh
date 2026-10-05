#!/usr/bin/env bash
# Flutter commands for a machine with little free memory (16 GB, no swap).
#
# Each command runs in its own systemd scope with a memory limit and at low
# priority, and only starts when enough memory is free. A command that grows
# past its limit is stopped by the kernel; the desktop is left alone.
#
#   tool/dev.sh run [args]       flutter run [args]         needs about 4.5 GB
#   tool/dev.sh build [args]     flutter build apk --debug  needs about 4.5 GB
#   tool/dev.sh test [args]      flutter test [args]        needs about 2 GB
#   tool/dev.sh analyze [paths]  dart analyze (lib and test by default)
#   tool/dev.sh mem              who uses the memory right now
#   tool/dev.sh tidy             stop Gradle and Kotlin daemons (not during a build)
#
# FORCE=1 skips the free-memory check.
set -euo pipefail
cd "$(dirname "$0")/.."

# Limits in MB. A debug build was measured at a peak of 4.2 GB for the whole
# scope (Gradle, the Kotlin daemon, the Dart compiler and the Flutter tool).
BUILD_LIMIT=5500
BUILD_NEEDS=4500
TEST_LIMIT=2500
TEST_NEEDS=2000

available_mb() { awk '/MemAvailable/ {print int($2 / 1024)}' /proc/meminfo; }

# PID and size of every Gradle or Kotlin daemon, whoever started it.
daemons() {
  ps -eo pid,rss,args | awk '$3 ~ /\/java$/ && /GradleDaemon|KotlinCompileDaemon/ {
    kind = /KotlinCompileDaemon/ ? "Kotlin" : "Gradle"
    printf "%s %d %s %s\n", $1, $2 / 1024, kind, $3
  }'
}

mem() {
  echo "Free for new programs: $(available_mb) MB"
  echo "Largest users:"
  ps -eo rss,comm | awk 'NR > 1 {sum[$2] += $1}
    END {for (name in sum) if (sum[name] > 300000) printf "  %5d MB  %s\n", sum[name] / 1024, name}' |
    sort -k1,1nr | head -8
  local found
  found=$(daemons)
  if [[ -n "$found" ]]; then
    echo "Gradle and Kotlin daemons (tool/dev.sh tidy stops them):"
    while read -r pid mb kind java; do
      echo "  $mb MB  $kind daemon, pid $pid, $java"
    done <<<"$found"
  fi
}

tidy() {
  local found
  found=$(daemons)
  if [[ -z "$found" ]]; then
    echo "No Gradle or Kotlin daemons are running."
    return
  fi
  while read -r pid mb kind _; do
    kill "$pid" && echo "Stopped $kind daemon, pid $pid ($mb MB)"
  done <<<"$found"
}

# capped <limit MB> <needed MB> <command...>
capped() {
  local limit=$1 needed=$2 have
  shift 2
  have=$(available_mb)
  if ((have < needed)) && [[ -z "${FORCE:-}" ]]; then
    {
      echo "Only $have MB of memory is free and this needs about $needed MB."
      mem
      echo "Close something or run 'tool/dev.sh tidy'. FORCE=1 runs it anyway."
    } >&2
    exit 1
  fi
  exec systemd-run --user --scope --quiet -p MemoryMax="${limit}M" nice -n 10 "$@"
}

command=${1:-}
shift || true
case "$command" in
  run) capped "$BUILD_LIMIT" "$BUILD_NEEDS" flutter run "$@" ;;
  build) capped "$BUILD_LIMIT" "$BUILD_NEEDS" flutter build apk --debug "$@" ;;
  test)
    # Two test files at a time unless the caller chose otherwise; the
    # default is one per CPU core, which multiplies the memory used.
    case " $* " in
      *" -j"* | *" --concurrency"*) capped "$TEST_LIMIT" "$TEST_NEEDS" flutter test "$@" ;;
      *) capped "$TEST_LIMIT" "$TEST_NEEDS" flutter test -j 2 "$@" ;;
    esac
    ;;
  analyze)
    if (($# == 0)); then set -- lib test; fi
    capped "$TEST_LIMIT" "$TEST_NEEDS" dart analyze "$@"
    ;;
  mem) mem ;;
  tidy) tidy ;;
  *)
    sed -n '2,/^set -euo/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac
