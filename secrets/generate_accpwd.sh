#!/bin/bash

SecureRegistry() {
  # remove the htpasswd
  rm -rf htpasswd_registry

  # generated the user's account and password
  # docker run --rm -it xmartlabs/htpasswd <user> <passwd> >> htpasswd_registry
  docker run --rm -it xmartlabs/htpasswd user passwd >> htpasswd_registry
}

SecureServer() {
  # remove the htpasswd for nginx
  rm -rf htpasswd

  # generated the user's account and password for nginx
  docker run --rm -it xmartlabs/htpasswd -Bm user passwd >> htpasswd
}

SecureServer