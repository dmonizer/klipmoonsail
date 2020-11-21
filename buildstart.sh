#!/bin/bash

PRINTER_DEVICE="/dev/serial/by-id/usb-1a86_USB2.0-Serial-if00-port0"
MAINSAIL_RELEASE="0.2.6"

########### end of configuration ##################333
ACTIONS=("init" "build" "run" "stop" "restart" "logs")

show_usage() {
	echo "usage: $0 <action> [parameters]" 
	echo "available actions: "
	for i in ${ACTIONS[@]}; do
		echo " " $i" "
	done
	echo ""
	
}

set_variables() {
	LOG_MOUNT="--mount type=bind,source=$(pwd)/runtime/logs,target=/logs"
	SDCARD_MOUNT="--mount type=bind,source=$(pwd)/runtime/sdcard,target=/sdcard"
	TMP_MOUNT="--mount type=bind,source=$(pwd)/runtime/tmp,target=/tmp"
	MOONRAKER_MOUNT="--mount type=bind,source=$(pwd)/runtime/config,target=/moonraker/config"
	KLIPPER_MOUNT="--mount type=bind,source=$(pwd)/runtime/config,target=/klipper/config"
	PRINTER_MOUNT="--device=$PRINTER_DEVICE"
	USERID=$(id -u)
	GROUPID=$(id -g)
	USER_ARGS="--user $UID:$GID"
	BUILD_ARGS="--build-arg UID=$USERID --build-arg GID=$GROUPID"
}

check_and_download() {
	echo -n "checking for klipper source ..."
	[ ! -d "klipper_docker/klipper" ] \
		&& echo -n "not present, cloning..." \ 
		#&& git clone https://github.com/KevinOConnor/klipper.git klipper_docker/klipper>/dev/null 
	echo "done"

	echo -n "checking for moonraker source ..."
	[ ! -d "moonraker_docker/moonraker" ] \
		&&  echo -n "not present, cloning..." \
		#&& git clone https://github.com/Arksine/moonraker.git moonraker_docker/moonraker>/dev/null 
	echo "done"

	echo -n "checking for moonraker source ..."
	[ ! -d "mainsail_docker/mainsail" ] \
		&&  echo -n "not present, downloading..." \
		#&& wget -O mainsail_docker/mainsail.zip https://github.com/meteyou/mainsail/releases/download/v$MAINSAIL_RELEASE/mainsail-beta-$MAINSAIL_RELEASE.zip >/dev/null\
		#&& echo -n "... unzipping ..." \
		#&& unzip mainsail_docker/mainsail.zip -d mainsail_docker/mainsail>/dev/null
	echo "done"
}

build_klipper() { 
	echo "Building klipper"
	echo docker build $BUILD_ARGS ./klipper_docker -t klipper
}

build_moonraker() { 
	echo "building moonraker"
	echo docker build $BUILD_ARGS ./moonraker_docker -t moonraker
}

build_mainsail() { 
	echo "Building mainsail:"
	echo docker build ./mainsail_docker -t mainsail
}

create_network(){
	echo docker network create --subnet=172.18.0.0/26 klipmoonsail
}

klipper_init() {
	echo "running only klipper for first-time config and flashing" 
	echo docker run -it --rm --name klipper-build $PRINTER_MOUNT --entrypoint /bin/bash klipper
}

start_klipper() {
	echo -n "Starting klipper ... "
	echo docker run --rm -d --name klipper $USER_ARGS $PRINTER_MOUNT $LOG_MOUNT $TMP_MOUNT $SDCARD_MOUNT $KLIPPER_MOUNT \
		--net klipmoonsail --hostname klipper.local --ip 172.18.0.23 klipper 
	echo done
}
start_moonraker() {
	echo -n "Starting moonraker ... "
	echo docker run --rm -d --name moonraker \
		$USER_ARGS $LOG_MOUNT $TMP_MOUNT $SDCARD_MOUNT $MOONRAKER_MOUNT \
		--net klipmoonsail  --hostname apiserver.local --ip 172.18.0.22 moonraker 
	echo done
}

start_mainsail() {
	echo -n "Starting mainsail ... "
	#docker run --rm -d --name mainsail -p 8080:80 --net klipmoonsail  --hostname mainsail.local --ip 172.18.0.21  mainsail 
	echo done
}	

action_logs () {
	tail -f runtime/logs/*log
}

action_run(){
	if [[ "$#" -eq "0" ]]; then
		echo "no container specified, running all"
		start_klipper
		start_moonraker
		start_mainsail
		exit	
	fi
	while [[ 0 -lt $#  ]]; do
		if [[ "$1" == "klipper" ]]; then
			start_klipper
		elif [[ "$1" == "mainsail" ]]; then
			start_mainsail
		elif [[ "$1" == "moonraker" ]]; then
			start_moonraker
		else
			echo "ERROR: invalid container name: $1"
			show_usage
		fi
		shift
	done
	exit
}

action_build() {
	echo "building image(s)"
	
	if [[ "$#" -eq "0" ]]; then
		echo "no container specified, building all"
		build_klipper
		build_moonraker
		build_mainsail
		exit	
	fi
	while [[ 0 -lt $#  ]]; do
		if [[ "$1" == "klipper" ]]; then
			build_klipper
		elif [[ "$1" == "mainsail" ]]; then
			build_mainsail
		elif [[ "$1" == "moonraker" ]]; then
			build_moonraker
		else
			echo "ERROR: invalid container name: $1"
			show_usage
		fi
		shift
	done
	exit

}


action_init() {
	check_and_download
	build_klipper
	create_network
	klipper_init
	echo "if all is correct, you should be able to run klipmoonsail now: $0 run"
}

action_stop(){
	for i in "klipper" "moonraker" "mainsail"; do
		docker stop $i
	done
}

action_restart(){
	action_stop
	start_klipper
	start_moonraker
	start_mainsail
}

if [[ $# -lt 1 ]]; then
	show_usage
	exit 1
fi
ACTION=$1
shift
PARAMETERS=$*

if [[ " ${ACTIONS[@]} " =~ " ${ACTION} " ]]; then
	
	set_variables
	
	if [[ "init" == "$ACTION" ]]; then
		action_init $PARAMETERS
	fi
	if [[ "run" == "$ACTION" ]]; then
		action_run $PARAMETERS
	fi
	if [[ "build" == "$ACTION" ]]; then
		action_build $PARAMETERS
	fi
	if [[ "stop" == "$ACTION" ]]; then
		action_stop
	fi
	if [[ "start" == "$ACTION" ]]; then
		action_start $PARAMETERS
	fi
	if [[ "restart" == "$ACTION" ]]; then
		action_restart
	fi
	if [[ "logs" == "$ACTION" ]]; then
		action_logs
	fi
fi


echo "all done"

