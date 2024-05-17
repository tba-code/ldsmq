#!/bib/bash

# Updates a given user with a new username and password.
# Required flags: -u -p
# Situaltional flags: -o [default: Ubuntu]

# Guard against running with regular permissions 
if [ "$EUID" -ne 0 ]
  then echo Please run this script as root or using sudo.
  exit
fi

# Argument parser
REQUIRED_ARGS=("USERNAME" "PRIVATE_NODE_IPS")
POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -u|--username)
      USERNAME="$2"
      shift # past argument
      shift # past value
      ;;
    -i|--ips)
      PRIVATE_NODE_IPS="$2"
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

# Update the hosts file
echo -e "\n# GFS Nodes"
count=0
for i in $PRIVATE_NODE_IPS; do
  count=$(( count + 1 ))
  echo -e "$i" "gfs$count"
done

# Inform the user
mkdir -p /etc/messages
echo "Please run step2.sh on all of your nodes before continuing." > "/etc/messages/${USERNAME}"
echo "Please run step2.sh on all of your nodes before continuing."