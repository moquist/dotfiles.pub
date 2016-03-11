#!/usr/bin/env bash
# Flatten a directory tree with depth two (subdirs with files) into a single set
# of files, prepending each filename with the name of the directory it was in.
#
# This makes the files sort properly on many players.

destination=$1 && shift
if [ ! "$destination" ]; then
    echo no destination directory specified
    exit 1
fi

if [ ! -d "$destination" ]; then
    echo "destination ($destination) doesn't exist"
    exit 1
fi

find . -type f \
    | sed -e 's#^\./##' \
          -e "s#^\(\([^/]\+\)/\(.*\)\)\$#cp -v \1 $destination/\2-\3#" \
    | bash
