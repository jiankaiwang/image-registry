# Image Registry

## How to use

Start the image registry service.

```sh
# git clone the service
git clone https://github.com/jiankaiwang/image-registry.git
cd ./image-registry

# bootstrap the necessary components
bash ./bootstrap.sh

# start the image registry service
bash ./make.sh start

# stop and delete the service
bash ./make.sh stop
```

For clients, how to use set the environment.

```sh
# for mac user
bash ./mac.sh help

# for linux user
bash ./ubuntu.sh help
```