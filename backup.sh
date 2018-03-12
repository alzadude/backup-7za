#!/usr/bin/env sh

#set -x

MEDIA=/mnt/e
TMPDIR=/tmp/backup
PASSWORD=${PASSWORD:-/etc/sysconfig/backup.password}
CONFIG=${CONFIG:-/etc/sysconfig/backup}
[ -f "$CONFIG" ] && . "$CONFIG"

expected="dirname basename expect 7za"
results=$(for cmd in $expected; do command -V $cmd; done)
actual=$(printf "%s\n" "$results" | while read first _; do printf "%s%s" "$sep" "${first%%*:}"; sep=" "; done)
[ "$expected" = "$actual" ] || { printf "Expected commands on PATH: %s, actual: %s\n" "$expected" "$actual" 1>&2; exit 1; }

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

mkdir -p ${TMPDIR}

# https://unix.stackexchange.com/questions/102891/posix-compliant-way-to-work-with-a-list-of-filenames-possibly-with-whitespace
set -f; IFS='
'
for dir in ${DIRS}; do
  set +f; unset IFS
  { cd "$dir" && \
    mkdir ${MEDIA}/"$(basename "$dir")".tmp && \
    $script_dir/7za.expect ${PASSWORD} a -p ${OPTS} -w${TMPDIR} ${MEDIA}/"$(basename "$dir")".tmp/"$(basename "$dir")".7z . && \
    $script_dir/7za.expect ${PASSWORD} t ${MEDIA}/"$(basename "$dir")".tmp/"$(basename "$dir")".7z.001 && \
    rm -rf ${MEDIA}/"$(basename "$dir")" && \
    mv ${MEDIA}/"$(basename "$dir")".tmp ${MEDIA}/"$(basename "$dir")"; } || exit $?
done
set +f; unset IFS

# TODO following should be in a trap

#set -f; IFS='
#'
#for dir in ${DIRS}; do
#  set +f; unset IFS
#  rm -rf ${MEDIA}/"$(basename "$dir")".tmp
#done
#set +f; unset IFS

rm -rf ${TMPDIR}
