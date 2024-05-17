#!/bin/bash

# Init script. Designed to run on instance creation.
# Required flags: -u -p -o -n - -w -m

# Guard against running with regular permissions 
if [ "$EUID" -ne 0 ]
  then echo Please run this script as root or using sudo.
  exit
fi

# Argument parser
REQUIRED_ARGS=("USERNAME" "PASSWORD" "ORIGINAL_USERNAME" "NODE_PREFIX" "NODE_ID" "WEBHOOK" "MESSAGE_PREFIX")
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -u|--username)
      USERNAME="$2"
      shift # past argument
      shift # past value
      ;;
    -p|--password)
      PASSWORD="$2"
      shift # past argument
      shift # past value
      ;;
    -o|--original-username)
      ORIGINAL_USERNAME="$2"
      shift # past argument
      shift # past value
      ;;
    -n|--node-prefix)
      NODE_PREFIX="$2"
      shift # past argument
      shift # past value
      ;;
    -i|--node-id)
      NODE_ID="$2"
      shift # past argument
      shift # past value
      ;;
    -w|--webhook)
      WEBHOOK="$2"
      shift # past argument
      shift # past value
      ;;
    -m|--message-prefix)
      MESSAGE_PREFIX="$2"
      shift # past argument
      shift # past value
      ;;
    -*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

# Exit if we are missing a required argument.
for arg_name in "${REQUIRED_ARGS[@]}"; do
  if [[ -z "${!arg_name}" ]]
    then echo "Missing required argument: ${arg_name}"
    exit
  fi
done

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
