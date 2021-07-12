#!/bin/bash

MAINSAIL_RELEASE="1.1.0"

########### end of configuration ##################333

ACTIONS=("init" "refresh" "build" "klipper_init" "run" "stop" "restart" "logs")

show_usage() {
  echo "usage: $0 <action> [parameters]"
  echo "available actions: "
  for i in "${ACTIONS[@]}"; do
    echo " $i "
  done
  echo ""
  
}

set_variables() {
  PRINTER_CGROUP="'c 188:* rmw'"
  WEBCAM_CGROUP="'c 81:* rmw'"
  PRINTER_ACCESS="-v /dev:/dev --device-cgroup-rule=$PRINTER_CGROUP --device-cgroup-rule=$WEBCAM_CGROUP"
  LOG_MOUNT="--mount type=bind,source=$(pwd)/runtime/logs,target=/logs"
  SDCARD_MOUNT="--mount type=bind,source=$(pwd)/runtime/sdcard,target=/sdcard"
  TMP_MOUNT="--mount type=bind,source=$(pwd)/runtime/tmp,target=/tmp"
  MOONRAKER_MOUNT="--mount type=bind,source=$(pwd)/runtime/config,target=/moonraker/config"
  KLIPPER_MOUNT="--mount type=bind,source=$(pwd)/runtime/config,target=/klipper/config"
  USERID=$(id -u)
  GROUPID=$(id -g)
  USER_ARGS="--user $UID:$GID"
  BUILD_ARGS="--build-arg UID=$USERID --build-arg GID=$GROUPID"
}

check_and_update() {
  echo -n "checking for klipper source ..."
  [ -d "klipper_docker/klipper" ] &&
  echo -n "present, refreshing..." && git pull >/dev/null
  echo "done"
  
  echo -n "checking for moonraker source ..."
  [ -d "moonraker_docker/moonraker" ] &&
  echo -n "present, refreshing..." &&
  git pull >/dev/null
  echo "done"
  
  echo -n "checking for mainsail source ..."
  [ -d "mainsail_docker/mainsail" ] &&
  echo -n "present, refreshing..." &&
  wget -q -O mainsail_docker/mainsail.zip https://github.com/meteyou/mainsail/releases/download/v$MAINSAIL_RELEASE/mainsail.zip >/dev/null && echo -n "... unzipping ..." &&
  unzip -d mainsail_docker/mainsail -fo mainsail_docker/mainsail.zip >/dev/null
  echo "done"
}

check_and_download() {
  echo -n "checking for klipper source ..."
  [ ! -d "klipper_docker/klipper" ] &&
  echo -n "not present, cloning..." && git clone https://github.com/KevinOConnor/klipper.git klipper_docker/klipper >/dev/null
  echo "done"
  
  echo -n "checking for moonraker source ..."
  [ ! -d "moonraker_docker/moonraker" ] &&
  echo -n "not present, cloning..." &&
  git clone https://github.com/Arksine/moonraker.git moonraker_docker/moonraker >/dev/null
  echo "done"
  
  echo -n "checking for mainsail source ..."
  [ ! -d "mainsail_docker/mainsail" ] &&
  echo -n "not present, downloading..." &&
  wget -O mainsail_docker/mainsail.zip https://github.com/meteyou/mainsail/releases/download/v$MAINSAIL_RELEASE/mainsail.zip >/dev/null && echo -n "... unzipping ..." &&
  unzip -d mainsail_docker/mainsail -fo mainsail_docker/mainsail.zip >/dev/null
  echo "done"
}

build_klipper() {
  echo "Building klipper"
  docker build "$BUILD_ARGS" ./klipper_docker -t klipper
}

build_moonraker() {
  echo "building moonraker"
  docker build "$BUILD_ARGS" ./moonraker_docker -t moonraker
}

build_mainsail() {
  echo "Building mainsail:"
  docker build ./mainsail_docker -t mainsail
}

create_network() {
  docker network create --subnet=172.18.0.0/26 klipmoonsail
}

klipper_init() {
  echo "running only klipper for first-time config and flashing"
  eval "docker run -it --rm --name klipper-build $PRINTER_ACCESS klipper /bin/bash"
}

start_klipper() {
  echo -n "Starting klipper ... "
  COMMAND="docker run --rm -d --name klipper $PRINTER_ACCESS $USER_ARGS $LOG_MOUNT $TMP_MOUNT $SDCARD_MOUNT $KLIPPER_MOUNT \
  --net klipmoonsail --hostname klipper.local --ip 172.18.0.23 klipper"
  echo "$COMMAND"
  eval "$COMMAND"
  echo "done"
}
start_moonraker() {
  echo -n "Starting moonraker ... "
  docker run --rm -d --name moonraker \
  "$USER_ARGS" "$LOG_MOUNT" "$TMP_MOUNT" "$SDCARD_MOUNT" "$MOONRAKER_MOUNT" \
  --net klipmoonsail --hostname apiserver.local --ip 172.18.0.22 moonraker
  echo "done"
}

start_mainsail() {
  echo -n "Starting mainsail ... "
  docker run --rm -d --name mainsail -p 8080:80 --net klipmoonsail --hostname mainsail.local --ip 172.18.0.21 mainsail
  echo "done"
}

action_logs() {
  tail -f runtime/logs/*log
}

action_run() {
  if [[ "$#" -eq "0" ]]; then
    echo "no container specified, running all"
    start_klipper
    start_moonraker
    start_mainsail
    exit
  fi
  while [[ 0 -lt $# ]]; do
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
  while [[ 0 -lt $# ]]; do
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

action_stop() {
  for i in "klipper" "moonraker" "mainsail"; do
    echo -n "stopping $i: "
    docker stop $i
  done
}

action_restart() {
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

if [[ "${ACTIONS[*]}" =~ ${ACTION} ]]; then
  
  set_variables
  
  case $ACTION in
    "refresh") check_and_update ;;
    "init") action_init "$PARAMETERS" ;;
    "run") action_run "$PARAMETERS" ;;
    "build") action_build "$PARAMETERS" ;;
    "klipper_init") klipper_init "$PARAMETERS" ;;
    "stop") action_stop ;;
    "start") action_start "$PARAMETERS" ;;
    "logs") action_logs ;;
    Default) show_usage ;;
  esac
fi

echo "all done"
