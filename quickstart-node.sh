#!/bin/bash

# Replace these with your values and then proceed to step 1.
curl "https://raw.githubusercontent.com/tba-code/ldsmq/main/scripts/step1.sh" | bash -s -- \
-u "your user" \
-i "ip1 ip2 ip3 ip4 ip5"

curl "https://raw.githubusercontent.com/tba-code/ldsmq/main/scripts/step2.sh" | bash -s -- \
-d "32G" \
-n "$(hostname | tail -c 2)"

