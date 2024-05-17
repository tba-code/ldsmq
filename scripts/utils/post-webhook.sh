#!/bin/bash

# Attempts to post a message via webhook.
# Required flags: -u -m

# Guard against running with regular permissions 
if [ "$EUID" -ne 0 ]
  then echo Please run this script as root or using sudo.
  exit
fi

# Argument parser
REQUIRED_ARGS=("URL" "MESSAGE")
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -u|--url)
      URL="$2"
      shift # past argument
      shift # past value
      ;;
    -m|--message)
      MESSAGE="$2"
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

# We should probably set the provider here.
# PROVIDER="discord"

# Create the message payload.
# TODO: Add ability to specify username and avatar if desired.
# TODO: add optional mentions.
# TODO: Vary structure by provider.
PAYLOAD="{\"content\": \"${MESSAGE}\"}"

# Attempt to post the webhook.
# TODO: Check result to determine if the message was actually posted or not.
curl -i -H "Accept: application/json" \
-H "Content-Type:application/json" \
-X POST --data "${PAYLOAD}" "${URL}"

# Print a message letting the user know execution has finished.
echo "${MESSAGE} has been posted."