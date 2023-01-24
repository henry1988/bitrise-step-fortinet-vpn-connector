#!/bin/bash
set -x

unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
  echo "Add yarn public keys"
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "Update repositories, installing ppp and openfortivpn"
  sudo apt-get update && sudo apt-get install -y ppp && sudo apt-get install -y openfortivpn

else

  echo "Installing openfortivpn on MacOS"
  brew install -y openfortivpn

fi

echo "Starting VPN connection with gateways - ${host}:${port}"
sudo nohup openfortivpn ${host}:${port} --password=${password} --username=${username} --trusted-cert ${trusted_cert} &> $BITRISE_DEPLOY_DIR/logs.txt &

echo "Waiting connection"
NUMBER_OF_RETRY=0
until fgrep -q "Tunnel is up" $BITRISE_DEPLOY_DIR/logs.txt || [ $NUMBER_OF_RETRY -eq 25 ]; do
  ((NUMBER_OF_RETRY++))
  cat $BITRISE_DEPLOY_DIR/logs.txt
  sleep 1;
done
