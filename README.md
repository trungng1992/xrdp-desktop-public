# vConsole

This project includes all documents for build and run xrdp container.
The container is built based on:
* Ubuntu 20.04
* Mate desktop
* Java JDK 1.8.0-271
* Google Chrome
* Firefox
* Locked-down panel

# Build
Run this command to build container
```shell
# Run script
# Default name of container: xrdp-desktop-public
./build.sh

# Or run below command to build container
image_name="xrdp-desktop-public" # modify 
tag_name="1.0" # modify tag name
docker build -t ${image_name}:${tag_name} .
```

# Run container to test
```
./run.sh
```