#!/bin/sh
LOG_MOUNT="--mount type=bind,source=$(pwd)/runtime/logs,target=/logs"
SDCARD_MOUNT="--mount type=bind,source=$(pwd)/runtime/sdcard,target=/sdcard"
TMP_MOUNT="--mount type=bind,source=$(pwd)/runtime/tmp,target=/tmp"
MOONRAKER_MOUNT="--mount type=bind,source=$(pwd)/runtime/config,target=/moonraker/config"
KLIPPER_MOUNT="--mount type=bind,source=$(pwd)/runtime/config,target=/klipper/config"
PRINTER_DEVICE="/dev/serial/by-id/usb-1a86_USB2.0-Serial-if00-port0"
PRINTER_MOUNT="--device=$PRINTER_DEVICE"
USERID=$(id -u)
GROUPID=$(id -g)
USER_ARGS="--user $UID:$GID"
BUILD_ARGS="--build-arg UID=$USERID --build-arg GID=$GROUPID"

[ ! -d "klipper_docker/klipper" ] && git clone https://github.com/KevinOConnor/klipper.git klipper_docker/klipper
[ ! -d "moonraker_docker/moonraker" ] && git clone https://github.com/Arksine/moonraker.git moonraker_docker/moonraker
[ ! -d "mainsail_docker/mainsail" ] && wget -O mainsail_docker/mainsail.zip https://github.com/meteyou/mainsail/releases/download/v0.2.6/mainsail-beta-0.2.6.zip\
&&	unzip mainsail_docker/mainsail.zip -d mainsail_docker/mainsail
 
docker build $BUILD_ARGS ./klipper_docker -t klipper
docker build $BUILD_ARGS ./moonraker_docker -t moonraker
docker build ./mainsail_docker -t mainsail

#docker network create --subnet=172.18.0.0/26 klipmoonsail
#run first-time config for klipper. comment out next line for subsequent runs
docker run -it --rm --name klipper-build $PRINTER_MOUNT --entrypoint /bin/bash klipper
#start moonraker
echo -n Starting klipper
docker run --rm -d --name klipper $USER_ARGS $PRINTER_MOUNT $LOG_MOUNT $TMP_MOUNT $SDCARD_MOUNT $KLIPPER_MOUNT --net klipmoonsail --hostname klipper.local --ip 172.18.0.23 klipper 
echo done
echo -n Starting moonraker ...
docker run --rm -d --name moonraker $USER_ARGS $LOG_MOUNT $TMP_MOUNT $SDCARD_MOUNT $MOONRAKER_MOUNT --net klipmoonsail  --hostname apiserver.local --ip 172.18.0.22 moonraker 
echo done
echo -n Starting mainsail ...
docker run --rm -d --name mainsail -p 8080:80 --net klipmoonsail  --hostname mainsail.local --ip 172.18.0.21  mainsail 
echo done
#tail -f runtime/logs/*log
