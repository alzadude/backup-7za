#!/usr/bin/env sh

set -e

MEDIA_OVERRIDE=${MEDIA}
TMPDIR=/tmp/backup
PASSWORD=${PASSWORD:-/etc/sysconfig/backup.password}
CONFIG=${CONFIG:-/etc/sysconfig/backup}
[ -f "$CONFIG" ] && . "$CONFIG"

if [ -n "$MEDIA_OVERRIDE" ]
then
  MEDIA="$MEDIA_OVERRIDE"
fi

expected="dirname rm mkdir sed expect 7za mv"
results=$(set +e; for cmd in $expected; do command -V $cmd; done; set -e)
actual=$(printf "%s\n" "$results" | while read first _; do printf "%s%s" "$sep" "${first%%*:}"; sep=" "; done)
[ "$expected" = "$actual" ] || { printf "Expected commands on PATH: %s, actual: %s\n" "$expected" "$actual" 1>&2; exit 1; }

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

trap "rm -rf ${MEDIA}/*.tmp; rm -rf ${TMPDIR}; exit" INT TERM EXIT

mkdir -p ${TMPDIR}

# https://unix.stackexchange.com/questions/102891/posix-compliant-way-to-work-with-a-list-of-filenames-possibly-with-whitespace
set -f; IFS='
'
for dir in ${DIRS}
do
  set +f; unset IFS
  cd "$dir"
  archive=$(printf '%s' "$dir" | sed -e 's/\//-/g' -e 's/-//1')
  mkdir "${MEDIA}/$archive.tmp"
  $script_dir/7za.expect ${PASSWORD} a -p ${OPTS} -w${TMPDIR} "${MEDIA}/$archive.tmp/$archive.7z" .
  $script_dir/7za.expect ${PASSWORD} t "${MEDIA}/$archive.tmp/$archive.7z.001"
  rm -rf "${MEDIA}/$archive"
  mv "${MEDIA}/$archive.tmp" "${MEDIA}/$archive"
done
set +f; unset IFS
