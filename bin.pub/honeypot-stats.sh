#!/bin/bash
# Calculate some quick stats from honeypot logs.
# Right now only supports crude parsing of dionaea bistream filenames.
# TODO:
#   parse kippo logs for auth attempts

CONF=.honeypot-stats.conf

############ defaults
# Default to listing the biggest/most frequent, etc.
SUMMARIZE='tail -n 5'

if [[ "$1" = "--verbose" ]]; then
    SUMMARIZE=cat
fi

# Default to listing the most frequently-connected IPs
OPERATIONS=frequent_ips

# Allow for defaults to be overwritten in conf
[[ -f $HOME/$CONF ]] && . $HOME/$CONF

############ CLI parsing
function usage {
    echo "Usage: " $(basename $0) " [-h | --help] [-v | --verbose] [-o | --operations <frequent_ips,frequent_ipproto,frequent_proto>]
    -c|--conf-sample  Print a sample ~/$CONF file.
    -h|--help         Print this help message.
    -v|--verbose      Do not limit output per operation.  (Default: tail -n 5)
    -o|--operations   Perform the specified operations.  (Default: frequent_ips)

    Defaults can be overwritten in ~/$CONF.
    "
}

function confsample {
    echo "\
# path to all dionaea bistream logs
dionaealogs_dirs=/var/dionaea/bistreams/*/

# grep regex to ignore hosts
ignorehosts=\"192.168.0.0\"

# default (non-verbose) output filter
# SUMMARIZE='tail -n 5'

# default operation
# OPERATIONS=frequent_ips
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

function get_proto_ipaddr {
    # Grab the protocol name and IP address from the name of the bistream file.
    sed 's/^\([^-]*\)-[0-9]\+-::ffff:\([^-]\+\)-.*$/\1 \2/'
}

function first {
    awk '{print $1}'
}
function second {
    awk '{print $2}'
}

############ stats functions
# List the most oft-connected IP addresses
function frequent_ips {
    echo
    echo ======== Most frequent connectors by IP address ========
    ls $dionaealogs_dirs \
        | grep -v $ignorehosts \
        | get_proto_ipaddr \
        | second \
        | grep . \
        | sort \
        | uniq -c \
        | sort -n \
        | $SUMMARIZE
}

# List the most frequent IP addresses + protocol name combos 
function frequent_ipproto {
    echo
    echo ======== Most frequent connectors by IP address + protocol name ========
    echo
    ls $dionaealogs_dirs \
        | grep -v $ignorehosts \
        | get_proto_ipaddr \
        | grep . \
        | sort \
        | uniq -c \
        | sort -n \
        | $SUMMARIZE
}

# List the most frequent protocol names
function frequent_proto {
    echo
    echo ======== Most frequent connectors by protocol name ========
    echo
    ls $dionaealogs_dirs \
        | grep -v $ignorehosts \
        | get_proto_ipaddr \
        | first \
        | grep . \
        | sort \
        | uniq -c \
        | sort -n \
        | $SUMMARIZE
}

############ do the work

echo $OPERATIONS
if [[ $OPERATIONS =~ frequent_ips ]]; then
    frequent_ips
fi
if [[ $OPERATIONS =~ frequent_ipproto ]]; then
    frequent_ipproto
fi
if [[ $OPERATIONS =~ frequent_proto ]]; then
    frequent_proto
fi
