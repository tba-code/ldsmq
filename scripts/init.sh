#!/bin/bash

# Fill these in
NODE_ID=
NODE_PREFIX=
WEBHOOK=
MESSAGE_PREFIX="${NODE_PREFIX}${NODE_ID}"
USERNAME=
PASSWORD=
ORIGINAL_USERNAME="ubuntu"

# Update username and password
curl https://raw.githubusercontent.com/tba-code/ldsmq/main/scripts/utils/change-default-user.sh | sudo bash -s -- \
-u "${USERNAME}" \
-o "${ORIGINAL_USERNAME}" \
-p "${PASSWORD}"

curl https://raw.githubusercontent.com/tba-code/ldsmq/main/scripts/utils/post-webhook.sh | sudo bash -s -- \
-u "${WEBHOOK}" \
-m "${MESSAGE_PREFIX}: Login credentials updated"

# Update hostname
hostnamectl set-hostname "${NODE_PREFIX}${NODE_ID}"

curl https://raw.githubusercontent.com/tba-code/ldsmq/main/scripts/utils/post-webhook.sh | sudo bash -s -- \
-u "${WEBHOOK}" \
-m "${MESSAGE_PREFIX}: Hostname changed"

# Install docker
curl https://raw.githubusercontent.com/tba-code/ldsmq/main/scripts/utils/get-docker.sh | sudo bash -s -- \
-u "${USERNAME}"

curl https://raw.githubusercontent.com/tba-code/ldsmq/main/scripts/utils/post-webhook.sh | sudo bash -s -- \
-u "${WEBHOOK}" \
-m "${MESSAGE_PREFIX}: Docker Installed"

# Install glusterfs
apt-get install glusterfs-server -y
systemctl start glusterd
systemctl enable glusterd

curl https://raw.githubusercontent.com/tba-code/ldsmq/main/scripts/utils/post-webhook.sh | sudo bash -s -- \
-u "${WEBHOOK}" \
-m "${MESSAGE_PREFIX}: GlusterFS Installed"

# Enable login messages.
echo "cat /etc/messages/${USERNAME}" >> "/home/${USERNAME}.bashrc"

# Send a discord notification to the user letting them know the instance is ready.
curl https://raw.githubusercontent.com/tba-code/ldsmq/main/scripts/utils/post-webhook.sh | sudo bash -s -- \
-u "${WEBHOOK}" \
-m "${MESSAGE_PREFIX} has finished initializing. Please refer to the guide for more details."
