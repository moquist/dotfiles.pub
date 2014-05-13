#!/bin/sh
# Received from Scott Salvidio via email 2010-03-03
# Modified by Matt Oquist (to make USERLIST use $1) Sat Apr  3 23:29:24 EDT 2010

# Script to add a user to OS X Panther.
# This does *not* add all pieces which are normally done through the Accounts
# System Pref Pane.  This also only works on an OS X client with NetInfo.
# Has not been fully tested for compatibility issues concerning missing pieces.

# Input format is:
#       Full Name,Shortname,YOG,Password
#       e.g.: John Smith,jsmith13,2013,mypassword
# The script should be run as:
#       provision-mac-users.sh studentexport.csv importfile.txt
# The importfile.txt can then be imported to Open Directory with:
#       dsimport importfile.txt /LDAPv3/127.0.0.1 I --username diradmin --password password

USERLIST=$1
OUTFILE=$2

if [ $# -lt 2 ] ; then
  echo "Command Syntax: "
  echo "$0 userlist.csv outputfile.txt"
  exit 1
fi

if [ ! -f "${USERLIST}" ] ; then
  echo "Can't find $USERLIST."
  exit 0
fi

if [ -f "${OUTFILE}" ] ; then
  echo "The file ${OUTFILE} already exists."
  exit 0
fi

MINUID=2000
SEARCHNODE=/LDAPv3/127.0.0.1

# Get the last UID used in the system.
LASTUID=$(dscl localhost -list "${SEARCHNODE}/Users" UniqueID | awk '{print $NF}' | sort -n | tail -1)

echo "last=$LASTUID"

# Always use UIDs with a minimum value of MINUID.  If last uid is greater than
# MINUID, just add 1 to it to get next available.
if [ $MINUID -gt $LASTUID ] ; then
   NEWUID=$MINUID
else
   NEWUID=$(($LASTUID + 1))
fi

# Check that shortname is not in use already
function verify_user()
{
  local USERNAME=$1

  local NAMEEXISTS=`id -u $USERNAME 2>&1 | grep -vc "no such user"`

  if [ "$NAMEEXISTS" = "0" ] ; then
     false
     return
  fi
  true
}


echo "Generating import file.."
echo

HEADERLINE="0x0A 0x5C 0x3A 0x2C dsRecTypeStandard:Users 10 dsAttrTypeStandard:RecordName dsAttrTypeStandard:AuthMethod dsAttrTypeStandard:Password dsAttrTypeStandard:UniqueID dsAttrTypeStandard:PrimaryGroupID  dsAttrTypeStandard:Comment dsAttrTypeStandard:RealName"

echo "${HEADERLINE}" > "${OUTFILE}"

IFS=$'\n\r'
for user in `cat "$USERLIST"`
do
    LONGNAME=`echo $user | awk 'BEGIN { FS="," } { print $1 }'`
    SHORTNAME=`echo $user | awk 'BEGIN { FS="," } { print $2 }' | tr A-Z a-z`
    YOG=`echo $user | awk 'BEGIN { FS="," } { print $3 }'`
    PASSWD=`echo $user | awk 'BEGIN { FS="," } { print $4 }'`

    if [ -z "$LONGNAME" ] || [ -z "${SHORTNAME}" ] || [ -z "${YOG}" ] || [ -z "${PASSWD}" ] ; then
       echo "Information missing in line. Skipping. (${user})"
       continue
    fi

    if verify_user "${SHORTNAME}"; then
      echo "User ${SHORTNAME} already exists.  Skipping."
      continue
    fi

    # for students, subtract 976 from the YOG to get the group ID... at least for now.
    #echo "${SHORTNAME}:dsAuthMethodStandard\:dsAuthClearText:${PASSWD}:${NEWUID}:$((YOG-976)):Student - ${YOG}:${LONGNAME}:" >> "${OUTFILE}"
    #echo "${SHORTNAME}:dsAuthMethodStandard\:dsAuthClearText:${PASSWD}:${NEWUID}:1046:Parent - ${YOG}:${LONGNAME}:" >> "${OUTFILE}"
    echo "${SHORTNAME}:dsAuthMethodStandard\:dsAuthClearText:${PASSWD}:${NEWUID}:20:Staff:${LONGNAME}:" >> "${OUTFILE}"

    NEWUID=$(($NEWUID + 1))
done
