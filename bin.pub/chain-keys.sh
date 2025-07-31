#!/usr/bin/env bash

set -e
if [ "$DEBUG" ]; then set -x; fi

ALLKEYS=${ALLKEYS:-"$HOME/.ssh/*_rsa"}

# http://www-128.ibm.com/developerworks/linux/library/l-keyc2/
if type -P keychain &>/dev/null; then
    keys=
    for key in $ALLKEYS; do [ -f "$key" ] && keys="${keys} $key "; done
    eval $(keychain --timeout ${KEYCHAIN_TIMEOUT_MINUTES:-1200} --nogui --eval $keys)
fi

