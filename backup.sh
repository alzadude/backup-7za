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

for dir in ${DIRS}; do \
  { cd $dir && \
    mkdir ${MEDIA}/$(basename $dir).tmp && \
    $script_dir/7za.expect ${PASSWORD} a -p ${OPTS} -w${TMPDIR} ${MEDIA}/$(basename $dir).tmp/$(basename $dir).7z . && \
    rm -rf ${MEDIA}/$(basename $dir) && \
    mv ${MEDIA}/$(basename $dir).tmp ${MEDIA}/$(basename $dir); } || exit $?; \
done

# TODO following should be in a trap

for dir in ${DIRS}; do rm -rf ${MEDIA}/$(basename $dir).tmp; done
rm -rf ${TMPDIR}
