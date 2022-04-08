#!/bin/bash
#
# Build Lapacke for all targets
#
if [[ $# -ne 1 ]]; then
  echo "Usage: build_all.sh /path/to/builddir"
  exit 2
fi

BUILDDIR=$1

FULL_PATH_TO_SCRIPT="$(realpath "$0")"
SCRIPT_DIRECTORY="$(dirname "$FULL_PATH_TO_SCRIPT")"

$SCRIPT_DIRECTORY/build_arch.sh $BUILDDIR x86_64
$SCRIPT_DIRECTORY/build_arch.sh $BUILDDIR armv7l
$SCRIPT_DIRECTORY/build_arch.sh $BUILDDIR aarch64
