#! /bin/bash

# Replace these with your values and then proceed to step 1.
curl https://raw.githubusercontent.com/tba-code/ldsmq/main/scripts/init.sh | bash -s -- \
-u "${USERNAME}" \
-o "${ORIGINAL_USERNAME}" \
-p "${PASSWORD}" \
-n "${NODE_PREFIX}" \
-i "${NODE_ID}" \
-w "${WEBHOOK}" \
-m "${MESSAGE_PREFIX}"