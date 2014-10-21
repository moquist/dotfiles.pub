#!/bin/bash
# Calculate some quick stats from honeypot logs.
# Right now only supports crude parsing of dionaea bistream filenames.
# TODO:
#   parse kippo logs for auth attempts

CONF=.honeypot-stats.conf

############ defaults
# Default to listing the biggest/most frequent, etc.
SUMMARIZE='tail -n 5'

# Default to listing the most frequently-connected IPs
OPERATIONS=dionaea_frequent_ips

# Allow for defaults to be overwritten in conf
[[ -f $HOME/$CONF ]] && . $HOME/$CONF

############ CLI parsing
function usage {
    echo "Usage: " $(basename $0) " [-h | --help] [-v | --verbose] [-o | --operations <list of operations>]
    -c|--conf-sample  Print a sample ~/$CONF file.
    -h|--help         Print this help message.
    -v|--verbose      Do not limit output per operation.  (Default: tail -n 5)
    -o|--operations   Perform the specified operations.  (Default: dionaea_frequent_ips)
                      Available operations include:
                          all # runs all ops
                          dionaea_frequent_ips
                          dionaea_frequent_ipproto
                          dionaea_frequent_proto
                          kippo_frequent_ips_attempts
                          kippo_frequent_ips_successes
                          kippo_frequent_usernames
                          kippo_frequent_passwords

                      For example, to do dionaea_frequent_ips and dionaea_frequent_proto: -o dionaea_frequent_ips,dionaea_frequent_proto

    Defaults can be overwritten in ~/$CONF.
    "
}

function confsample {
    echo "\
# path to all dionaea bistream logs
dionaealogs_dirs=/var/dionaea/bistreams/*/

# path to kippo logs
kippologs_dir=/var/kippo/log

# grep regex to ignore hosts
ignorehosts=\"192.168.0.0\"

# default (non-verbose) output filter
# SUMMARIZE='tail -n 5'

# default operation
# OPERATIONS=dionaea_frequent_ips
"
}

TEMP=`getopt -o c,h,o:,v --long conf-sample,help,operations:,verbose -- "$@"`
if [ $? != 0 ] ; then echo "bad getopt exit" >&2 ; exit 1 ; fi
eval set -- "$TEMP"
while true ; do
    case "$1" in
	-c|--conf-sample) confsample; exit 0 ;;
        -h|--help) usage; exit 0 ;;
        -v|--verbose) SUMMARIZE=cat; shift 1 ;;
        -o|--operations) OPERATIONS=$2; shift 2 ;;
	--) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

function dionaea_get_proto_ipaddr {
    # Grab the protocol name and IP address from the name of the bistream file.
    # Yep, we're only doing IPv4 for now.
    sed 's/^\([^-]*\)-[0-9]\+-::ffff:\([^-]\+\)-.*$/\1 \2/'
}

function kippo_get_ipaddr {
    awk -F, '{print $3}' | sed 's/].*$//'
}

function kippo_get_unpw {
    sed 's#^.*login attempt \[\([^/]\+\)/\(.\+\)\].*$#\1 \2#'
}

function first {
    awk '{print $1}'
}
function second {
    awk '{print $2}'
}

function tidy_sort_count {
    grep . | sort | uniq -c | sort -n
}

############ stats functions
# Dionaea: List the most oft-connected IP addresses
function dionaea_frequent_ips {
    echo
    echo "======== ($FUNCNAME) Dionaea: Most frequent connectors by IP address ========"
    ls $dionaealogs_dirs \
        | grep -v $ignorehosts \
        | dionaea_get_proto_ipaddr \
        | second \
        | tidy_sort_count \
        | $SUMMARIZE
}

# Dionaea: List the most frequent IP addresses + protocol name combos 
function dionaea_frequent_ipproto {
    echo
    echo "======== ($FUNCNAME) Dionaea: Most frequent connectors by IP address + protocol name ========"
    echo
    ls $dionaealogs_dirs \
        | grep -v $ignorehosts \
        | dionaea_get_proto_ipaddr \
        | tidy_sort_count \
        | $SUMMARIZE
}

# Dionaea: List the most frequent protocol names
function dionaea_frequent_proto {
    echo
    echo "======== ($FUNCNAME) Dionaea: Most frequent connectors by protocol name ========"
    echo
    ls $dionaealogs_dirs \
        | grep -v $ignorehosts \
        | dionaea_get_proto_ipaddr \
        | first \
        | tidy_sort_count \
        | $SUMMARIZE
}

# Kippo: List the most frequent IPs
function kippo_frequent_ips {
    indicator='login attempt'
    if [[ $1 = "successes" ]]; then
	indicator='root authenticated with keyboard-interactive'
    fi

    cat $kippologs_dir/*.log* \
        | grep "$indicator" \
        | grep -v $ignorehosts \
        | kippo_get_ipaddr \
        | tidy_sort_count \
        | $SUMMARIZE
}

function kippo_frequent_ips_attempts {
    echo
    echo "======== ($FUNCNAME) Kippo: Most frequent SSH attempts by IP address ========"
    echo
    kippo_frequent_ips attempts
}

function kippo_frequent_ips_successes {
    echo
    echo "======== ($FUNCNAME) Kippo: Most frequent SSH success by IP address ========"
    echo
    kippo_frequent_ips successes
}

# Kippo: List the most frequent usernames/passwords
function kippo_frequent_unpw {
    sel=first
    if [[ $1 = "passwords" ]]; then
        sel=second
    fi

    cat $kippologs_dir/*.log* \
        | grep 'login attempt' \
        | grep -v $ignorehosts \
        | kippo_get_unpw \
        | $sel \
        | tidy_sort_count \
        | $SUMMARIZE
}

function kippo_frequent_usernames {
    echo
    echo "======== ($FUNCNAME) Kippo: Most frequent usernames ========"
    echo
    kippo_frequent_unpw usernames
}

function kippo_frequent_passwords {
    echo
    echo "======== ($FUNCNAME) Kippo: Most frequent passwords ========"
    echo
    kippo_frequent_unpw passwords
}

############ do the work

for f in dionaea_frequent_ips dionaea_frequent_ipproto dionaea_frequent_proto kippo_frequent_ips_attempts kippo_frequent_ips_successes kippo_frequent_usernames kippo_frequent_passwords; do
    if [[ $OPERATIONS = "all" || $OPERATIONS =~ $f ]]; then
        $f
    fi
done
