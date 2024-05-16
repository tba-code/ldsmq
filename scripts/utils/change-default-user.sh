#!/bin/bash

# Updates a given user with a new username and password.
# Required flags: -u -p
# Situaltional flags: -o [default: Ubuntu]

# Guard against running with regular permissions 
if [ "$EUID" -ne 0 ]
  then echo Please run this script as root or using sudo.
  exit
fi

# Argument parser
REQUIRED_ARGS=("USERNAME" "PASSWORD")
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

# Set default username value if it isn't set.
ORIGINAL_USERNAME="${ORIGINAL_USERNAME:=Ubuntu}"

# Exit if the specified user does not exist.
if ! id "${ORIGINAL_USERNAME}" >/dev/null 2>&1; then
    echo "User ${ORIGINAL_USERNAME} not found."
    exit
fi

# Change username
usermod -l "${USERNAME}" "${ORIGINAL_USERNAME}"
groupmod -n "${USERNAME}" "${ORIGINAL_USERNAME}"
usermod -d "/home/${USERNAME}" -m "${USERNAME}"

# Change password automatically
usermod --password "$(echo "${PASSWORD}" | openssl passwd -1 -stdin)" "${USERNAME}"

# Print a message letting the user know execution has finished.
echo "${ORIGINAL_USERNAME} has been renamed to ${USERNAME} and their passowrd has been updated."