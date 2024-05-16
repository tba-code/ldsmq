#!/bin/bash

# Install and configure glusterfs
# Required flags: -u -p
# Situaltional flags: -o [default: Ubuntu]

# Guard against running with regular permissions 
if [ "$EUID" -ne 0 ]
  then echo Please run this script as root or using sudo.
  exit
fi

# Argument parser
REQUIRED_ARGS=("SWARM_SIZE" "USERNAME")
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -s|--swarm-size)
      SWARM_SIZE="$2"
      shift # past argument
      shift # past value
      ;;
    -u|--username)
      USERNAME="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
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
for arg_name in ${REQUIRED_ARGS[@]}; do
  if [[ -z "${!arg_name}" ]]
    then echo "Missing required argument: ${arg_name}"
    exit
  fi
done

# Peer the nodes
#for i in $(seq 1 $SWARM_SIZE); do gluster peer probe gfs$i; done

# Create the gfs volume
VOL_CMD_STRING="gluster volume create gfs replica ${SWARM_SIZE}"
for i in $(seq 1 $SWARM_SIZE); do
  VOL_CMD_STRING="${VOL_CMD_STRING} gfs${i}:/gluster/bricks/${i}/brick"
done

echo "${VOL_CMD_STRING}"
eval "${VOL_CMD_STRING}"

