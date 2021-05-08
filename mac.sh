#!/bin/bash
# maintainer: JianKai Wang <https://jiankaiwang.no-ip.biz/>

OPTION=$1
VALUE=$2 || "_not"

ErrorMsg() {
  # the error message
  printf "Error: $1\n"
}

Sudoer() {
  if ! [ $(id -u) = 0 ]; then
    echo "The script need to be run as root."
    echo "Please run with sudo."
    exit 1
  fi
}

AddCert() {
  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $1;
  echo "Add the certificate at $1.";
}

RemoveCert() {
  sudo security delete-certificate -c "$1";
  echo "Remove the certificate named $1";
}

RestartDocker() {
  killall Docker && open /Applications/Docker.app
  echo "Restart the docker engine."
}

if [ $# -eq 0 ] || [ $OPTION == "help" ] || [ $OPTION == "-h" ] || [ $OPTION == "--help" ]; then
  echo "Usage:"
  echo "  bash mac.sh [option]"
  echo "Option:"
  echo "  add:    add a certificate"
  echo "  remove: remove the certificate"
elif [ $OPTION == "add" ]; then
  if [ ! -f $VALUE ] || [ ! -r $VALUE ] || [ $# -eq 1 ]; then
    ErrorMsg "The certificate can't be found or read."
    exit 2;
  fi
  Sudoer
  AddCert $VALUE || ErrorMsg "Failed in adding the certificate, $VALUE.";
  RestartDocker
elif [ $OPTION == "remove" ]; then
  Sudoer
  RemoveCert $VALUE || ErrorMsg "Failed in deleting the certificate named $VALUE";
  RestartDocker
else
  ErrorMsg "The option $OPTION is not allowed."
  exit 1;
fi

exit 0;