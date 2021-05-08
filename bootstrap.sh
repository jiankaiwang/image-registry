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

# -----------------------------------------------------------------------------
# The following variables can be changed manually.
# CERTDAYS:     the period for certificate
# COUNTRY:      the country name
# STATENAME:    the state name
# LOCALITYNAME: the locality name
# ORGNAME:      the organization name
# ORGUNITNAME:  the organization unit name
# COMMONNAME:   the common name or server name
# -----------------------------------------------------------------------------
CERTDAYS=365
COUNTRY=TW
STATENAME=Taiwan
LOCALITYNAME=Taipei
ORGNAME=Self
ORGUNITNAME=Self
COMMONNAME=registry

# -----------------------------------------------------------------------------
ErrorMsg() {
  # the error message
  printf "Error: $1\n"
}

if [ ! -d $ROOT ] || [ ! -d $SERVER ] || [ ! -d $SECRETS ] || [ ! -d $VOLUME ]; then
  ErrorMsg "One of the $ROOT, $SERVER, $SECRETS, $VOLUME path was not found.";
  exit 1;
fi

# check if the configure files exist under server
configs=("hubconfig.yaml" "registry.conf" "registry_template.yaml" "gc.yaml")
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

# replace all paths to the docker-compose file
cp $SERVER/registry_template.yaml $SERVER/registry.yaml
VOLUMEPATH=$(echo $VOLUME | sed 's_/_\\/_g')
SECRETSPATH=$(echo $SECRETS | sed 's_/_\\/_g')
SERVERPATH=$(echo $SERVER | sed 's_/_\\/_g')

ostype="$(uname -s)"
case "$ostype" in
  Darwin*) 
    sed -i "" "s/VOLUME_REPLACED/$VOLUMEPATH/g" $SERVER/registry.yaml;
    sed -i "" "s/SECRETS_REPLACED/$SECRETSPATH/g" $SERVER/registry.yaml;
    sed -i "" "s/SERVER_REPLACED/$SERVERPATH/g" $SERVER/registry.yaml;;
  *)
    sed -i "s/VOLUME_REPLACED/$VOLUMEPATH/g" $SERVER/registry.yaml;
    sed -i "s/SECRETS_REPLACED/$SECRETSPATH/g" $SERVER/registry.yaml;
    sed -i "s/SERVER_REPLACED/$SERVERPATH/g" $SERVER/registry.yaml;;
esac

# generate the ssl certificate for nginx
while true; do
  echo "Generate the new certificate? Yn"
  read Yn
  case "$Yn" in 
    [Yy]* )
      echo "Generated the new ssl certificate for NGINX.";
      docker run -it --rm -v $SECRETS:/export \
        frapsoft/openssl req -x509 -nodes -new -days $CERTDAYS -newkey rsa:2048 -sha256 \
        -keyout /export/nginx.key -out /export/nginx.cert \
        -subj "/C=$COUNTRY/ST=$STATENAME/L=$LOCALITYNAME/O=$ORGNAME/OU=$ORGUNITNAME/CN=$COMMONNAME"
      break;;
    [Nn]* )
      echo "Not to generate certificate for NGINX.";
      break;;
    * )
      echo "Please answer yes or no.";;
  esac
done

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
# docker run -it --rm xmartlabs/htpasswd user user > ./secrets/htpasswd_registry
HTPASSWDFILE=$SECRETS/htpasswd
if [ ! -f $HTPASSWDFILE ] || [ ! -r $HTPASSWDFILE ]; then
  ErrorMsg "The htpasswd file $HTPASSWDFILE was not found.";
  exit 5;
fi

echo "\n[Congratulation!] You are ready to startup a private dockerhub registry.\n"
exit 0;
