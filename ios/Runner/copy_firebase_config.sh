#!/bin/sh

case "${CONFIGURATION}" in
  *\"staging\"*)
    BUILD_ENV="staging"
    ;;
  *)
    BUILD_ENV="prod"
    ;;
esac

echo "Copying Firebase config for environment: ${BUILD_ENV} (Configuration: ${CONFIGURATION})"

CONFIG_FILE="${SRCROOT}/config/${BUILD_ENV}/GoogleService-Info.plist"
DEST_FILE="${SRCROOT}/Runner/GoogleService-Info.plist"

if [ -f "${CONFIG_FILE}" ]; then
  echo "Found ${CONFIG_FILE}, copying to ${DEST_FILE}..."
  cp "${CONFIG_FILE}" "${DEST_FILE}"
else
  echo "Error: GoogleService-Info.plist not found for environment ${BUILD_ENV} at path ${CONFIG_FILE}"
  exit 1
fi
