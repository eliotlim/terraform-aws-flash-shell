#!/bin/sh

# Download resources from S3 resources bucket if defined
if [ -n "${RESOURCES_BUCKET}" ]; then
  echo "Downloading resources from s3://${RESOURCES_BUCKET}"

  for resource in ${RESOURCES}; do
    aws s3 cp "s3://${RESOURCES_BUCKET}/$resource" "./${resource}"
  done
fi

if [ -n "${SSH_KEYPAIR_SECRET_ID}" ]; then
  echo "Retrieving SSH keypair from ${SSH_KEYPAIR_SECRET_ID}"
  aws secretsmanager get-secret-value --query SecretString --output text --secret-id "${SSH_KEYPAIR_SECRET_ID}" > ./id_rsa
  chmod 400 ./id_rsa
fi

# Run command
$@

# Cleanup
echo "Task execution completed"
rm -rf ./id_rsa
