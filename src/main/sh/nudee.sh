#!/bin/bash

##
##  Unpack an artifact and start it
##



SERVICE_COORDINATE="$1"
shift

# Pick up artifact
ARTIFACT="$1"
shift

# The root of the copg unpacking directory
COPKG_ROOT="$1"
shift

# Then parse the service coordinate

CELLNAME=$(echo $SERVICE_COORDINATE | awk -F. '{print $4}')
USERNAME=$(echo $SERVICE_COORDINATE | awk -F. '{print $3}')
SERVICENAME=$(echo $SERVICE_COORDINATE | awk -F. '{print $2}')
INSTANCENO=$(echo $SERVICE_COORDINATE | awk -F. '{print $1}')

if [ -z "$USERNAME" ] ; then
  echo "No username in coordinate: $SERVICE_COORDINATE"
  exit 1
fi


if [ -z "$CELLNAME" ] ; then
  echo "No cellname in coordinate: $SERVICE_COORDINATE"
  exit 1
fi


if [ -z  "$SERVICENAME" ] ; then
  echo "No servicename in coordinate: $SERVICE_COORDINATE"
  exit 1
fi

if [  -z "$INSTANCENO" ] ; then
  echo "No instanceno in coordinate: $SERVICE_COORDINATE"
  exit 1
fi


if [ ! -f "$ARTIFACT" ] ; then
  echo "Could not find $ARTIFACT"
  exit 1
fi

# Calculate the exact coordinate to upack the artifact
# into.

COPKG_HOME="${COPKG_ROOT}/${SERVICE_COORDINATE}"

# nuke the old target and unpack a new one from the artifact
if [ -e "$COPKG_HOME" ] ; then
    rm -rf "$COPKG_HOME"
fi
mkdir -p "${COPKG_HOME}"

# Then unzip a new copkg directory, be quiet about 
# it (no logging to standard output)
unzip -q "$ARTIFACT" -d "$COPKG_HOME"  || (echo "Unzip returned failure, bailing out" && exit 1)

# Check that there is a startup script in there
STARTUP_SCRIPT="etc/start.sh"
if [ ! -e "${COPKG_HOME}/$STARTUP_SCRIPT" ] ; then
  echo "Could not find startup script '${STARTUP_SCRIPT}' in package '${ARTIFACT}'."
  exit 1
fi

# Let it rip...
cd "$COPKG_HOME"
exec /bin/sh "$STARTUP_SCRIPT" "$@"
