#!/bin/bash

# configure glusterfs storage
# Required flags: -d -n

# Guard against running with regular permissions 
if [ "$EUID" -ne 0 ]
  then echo Please run this script as root or using sudo.
  exit
fi

# Argument parser
REQUIRED_ARGS=("DEVICE_ID" "NODE_ID")
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--device-size)
      DEVICE_ID="$2"
      shift # past argument
      shift # past value
      ;;
    -n|--node-id)
      NODE_ID="$2"
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

# Prep the block device
mkfs.xfs -f -L gfs-volumes "/dev/${DEVICE_ID}"
mkdir "/gluster/bricks/${NODE_ID}" -p

# Update fstab to mount the disk at boot
echo "LABEL=gfs-volumes /gluster/bricks/${NODE_ID} xfs defaults 0 0" >> /etc/fstab
mount -a
mkdir "/gluster/bricks/${NODE_ID}/brick"

rm -rf /etc/messages

echo "Step 2 complete. On node 1, please run step 3."