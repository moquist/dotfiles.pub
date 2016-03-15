#!/usr/bin/env bash

# http://www-128.ibm.com/developerworks/linux/library/l-keyc2/
if type -P keychain &>/dev/null; then
    allkeys="$HOME/.ssh/*_rsa"
    keys=
    for key in $allkeys; do [ -f "$key" ] && keys="${keys} $key "; done
    eval $(keychain --timeout ${KEYCHAIN_TIMEOUT:-15} --nogui --eval $keys)
fi

