#!/bin/bash
# maintainer: JianKai Wang <https://jiankaiwang.no-ip.biz/>

# -----------------------------------------------------------------------------
# The following variables can be changed manually.
# ROOT:    the root path of the private docker registry service
# SECRETS: the path to all secret files, the default path is under ROOT
# VOLUME:  the path on host to keep all images
# -----------------------------------------------------------------------------
ROOT=$PWD
SERVER=$ROOT/server
SECRETS=$ROOT/secrets
VOLUME=$ROOT/volume

OPTION=$1

ErrorMsg() {
  # the error message
  printf "Error: $1\n"
  printf "(Please run sh ./bootstrap.sh first.)\n"
}

CheckServerPath() {
  if [ ! -d $ROOT ] || [ ! -d $SERVER ] || [ ! -d $SECRETS ] || [ ! -d $VOLUME ]; then
    ErrorMsg "One of the $ROOT, $SERVER, $SECRETS, $VOLUME path was not found.";
    exit 1;
  fi

  # check if the configure files exist under server
  configs=("hubconfig.yaml" "registry.conf" "registry.yaml" "gc.yaml")
  for config in "${configs[@]}"
  do
    filePath="$SERVER/$config"
    if [ ! -f $filePath ] || [ ! -r $filePath ]; then
      ErrorMsg "The file $filePath can not be written.";
      exit 2;
    fi
  done

  # check the paths that can be written
  paths=("$SECRETS" "$VOLUME" "$SERVER")
  for path in "${paths[@]}"
  do
    if [ ! -w $path ]; then
      ErrorMsg "The path $path can not be written.";
      exit 3;
    fi
  done

  # check the ssl certificate
  sslFiles=("nginx.key" "nginx.cert")
  for file in "${sslFiles[@]}"
  do
    sslFile=$SECRETS/$file
    if [ ! -f $sslFile ] || [ ! -r $sslFile ]; then
      ErrorMsg "Failed in generating the SSL certificate. The file $sslFile can not be found.";
      exit 4;
    fi
  done 

  # for registry
  HTPASSWDFILE=$SECRETS/htpasswd_registry
  if [ ! -f $HTPASSWDFILE ] || [ ! -r $HTPASSWDFILE ]; then
    ErrorMsg "The htpasswd file $HTPASSWDFILE was not found.";
    exit 5;
  fi
}

if [ $# -eq 0 ] || [ $OPTION == "help" ] || [ $OPTION == "-h" ] || [ $OPTION == "--help" ]; then
  echo "Usage:"
  echo "  bash make.sh [option]\n"
  echo "Option:"
  echo "  start:  start the private dockerhub registry service"
  echo "  stop:   stop the service"
  echo "  reload: reload the server to use the new configure"
elif [ $OPTION == "start" ]; then
  CheckServerPath
  echo "Start the private dockerhub registry service."

  # start the image registry
  docker compose -f $SERVER/registry.yaml up -d
elif [ $OPTION == "stop" ]; then
  docker compose -f $SERVER/registry.yaml down
elif [ $OPTION == "reload" ]; then
  docker exec -it httpserver nginx -s reload
fi

