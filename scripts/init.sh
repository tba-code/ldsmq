#!/bin/bash

# Copy variables below this line
USERNAME=
PASSWORD=
WEBHOOK=
NODE_PREFIX='node-'
NODE_ID="1"
SWARM_SIZE=5
DISK_SIZE="32G"
ORIGINAL_USERNAME="Ubuntu"
MESSAGE="${NODE_PREFIX}${NODE_ID} has finished initializing. Please log in and follow the provided instructions."

# Clone the convenience scripts repo to disk.
git clone 'https://github.com/tba-code/ldsmq.git'

# Make sure scripts are executable. Also, give the user ownsership.
readarray -d '' ldsmq_scripts < <(find ldsmq/scripts -name '*.sh' -type f)
for script in "${scripts}"; do
  chown -r "${USERNAME}:${USERNAME}" ldsmq
  chmod +x "${script}"
done

# Update username and password
"./ldsmq/scripts/utils/change-default-user.sh"\
"-u ${USERNAME} "\
"-o ${ORIGINAL_USERNAME} "\
"-p ${PASSWORD} "

# Update hostname
hostnamectl set-hostname "${NODE_PREFIX}${NODE_ID}"

# Install docker
"./ldsmq/scripts/utils/get-docker.sh"\
"-u ${USERNAME}"

# Install glusterfs
apt-get install glusterfs-server -y
systemctl start glusterd
systemctl enable glusterd

# Enable login messages.
echo "cat /etc/messages/${USERNAME}" >> "/home/${USERNAME}.bashrc"

# Send a discord notification to the user letting them know the instance is ready.
"./ldsmq/scripts/utils/change-default-user.sh"\
"-u ${WEBHOOK_URL} "\
"-m ${MESSAGE} "
