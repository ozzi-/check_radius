#!/bin/bash

# startup checks
if [ -z "$BASH" ]; then
  echo "Please use BASH."
  exit 3
fi
if [ ! -e "/usr/bin/which" ]; then
  echo "/usr/bin/which is missing."
  exit 3
fi
radclient=$(which radclient)
if [ $? -ne 0 ]; then
  echo "Please install 'radclient'."
  exit 3
fi

# Usage Info
usage() {
  echo '''Usage: check_radius [OPTIONS]
  [OPTIONS]:
  -H HOST           IP or Hostname
  -S SECRET         Shared Secret
  -W WARNING        Warning threshold in milliseconds (default: 700)
  -C CRITICAL       Critical threshold in milliseconds (default: 2000)'''
}

host=""
secret=""
warning=700
critical=2000

#main
#get options
while getopts "H:S:C:W:" opt; do
  case $opt in
    H)
      host=$OPTARG
      ;;
    S)
      secret=$OPTARG
      ;;
    W)
      warning=$OPTARG
      ;;
    C)
      critical=$OPTARG
      ;;
    *)
      usage
      exit 3
      ;;
  esac
done

# required checks
if [ -z "$host" ] || [ $# -eq 0 ]; then
  echo "Error: host is required"
  usage
  exit 3
fi
if [ -z "$secret" ] || [ $# -eq 0 ]; then
  echo "Error: Shared secret is required"
  usage
  exit 3
fi
timeout=$(($critical + 1))

start=$(echo $(($(date +%s%N)/1000000)))
res=$(echo "Message-Authenticator = 0x02" | radclient $host auth $secret -r 1 -t $timeout -x 2>&1)
end=$(echo $(($(date +%s%N)/1000000)))
runtime=$((end - start))

succeeded=false
if [[ $res == *"Received Access"* ]]; then
  succeeded=true
fi


if [ $succeeded ]; then
  if [ $runtime -gt $critical ]; then
    echo "CRITICAL: Server responds but critically slow |time="$runtime"ms;";
    exit 2;
  elif [ $runtime -gt $warning ]; then
    echo "WARNING: Server responds but sluggish |time="$runtime"ms;";
    exit 1;
  else
    echo "OK |time="$runtime"ms;";
    exit 0;
  fi
else
  echo "CRITICAL: Failed to connect to radius server|time="$runtime"ms;"
  exit 2
fi
