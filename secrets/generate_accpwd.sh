#!/bin/bash

# remove the htpasswd
rm -rf htpasswd_registry

# generated the user's account and password
# docker run --rm -it xmartlabs/htpasswd <user> <passwd> >> htpasswd_registry
docker run --rm -it xmartlabs/htpasswd user passwd >> htpasswd_registry