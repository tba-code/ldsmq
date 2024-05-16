#!/bin/bash

# Cleans up the setup utilities.
# Required flags: -u

# Guard against running with regular permissions 
if [ "$EUID" -ne 0 ]
  then echo Please run this script as root or using sudo.
  exit
fi

# Argument parser
REQUIRED_ARGS=("USERNAME")
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -u|--username)
      USERNAME="$2"
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

# Exit if the specified user does not exist.
if ! id "${USERNAME}" >/dev/null 2>&1; then
    echo "User ${USERNAME} not found."
    exit
fi

sed -i '$ d' "/home/${USERNAME}/.bashrc"
if [ -f "/etc/messages/${USERNAME}" ]; then
  rm "/etc/messages/${USERNAME}"
fi

rm -rf "/home/${USERNAME}/ldsmq"