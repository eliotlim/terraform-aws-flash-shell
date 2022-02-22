#!/bin/sh

# Download resources from S3 resources bucket if defined
if [ -n "${RESOURCES_BUCKET}" ]; then
  echo "Downloading resources from s3://${RESOURCES_BUCKET}"

  for resource in ${RESOURCES}; do
    aws s3 cp "s3://${RESOURCES_BUCKET}/$resource" "./${resource}"
  done
fi

# Run command
$@
