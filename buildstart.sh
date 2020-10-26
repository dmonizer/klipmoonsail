#!/bin/sh
LOG_MOUNT="--mount type=bind,source=$(pwd)/runtime/logs,target=/logs"
SDCARD_MOUNT="--mount type=bind,source=$(pwd)/runtime/sdcard,target=/sdcard"
TMP_MOUNT="--mount type=bind,source=$(pwd)/runtime/tmp,target=/tmp"
MOONRAKER_MOUNT="--mount type=bind,source=$(pwd)/runtime/config,target=/moonraker/config"
KLIPPER_MOUNT="--mount type=bind,source=$(pwd)/runtime/config,target=/klipper/config"

[ ! -d "klipper_docker/klipper" ] && git clone https://github.com/KevinOConnor/klipper.git klipper_docker/
[ ! -d "moonraker_docker/moonraker" ] && git clone https://github.com/Arksine/moonraker.gitc
[ ! -f "mainsail_docker/mainsail.zip" ] && wget -O mainsail_docker/mainsail.zip https://github.com/meteyou/mainsail/releases/download/v0.2.4/mainsail-beta-0.2.4.zip\
	unzip mainsail_docker/mainsail.zip -d mainsail_docker/mainsail
 
docker build ./klipper_docker -t klipper
#docker build ./moonraker_docker -t moonraker
#start moonraker
#docker run --rm -it moonraker 
#docker run --rm -it $TMP_MOUNT $SDCARD_MOUNT $MOONRAKER_MOUNT moonraker 
#docker run --rm -it $TMP_MOUNT $SDCARD_MOUNT $MOONRAKER_MOUNT klipper 
#tail -f runtime/logs/*log 
#sudo docker run -it --rm --network=host --mount type=bind,source=$(pwd)/klipper-conf,target=/3d_print/klipper_config klipmoonsail
