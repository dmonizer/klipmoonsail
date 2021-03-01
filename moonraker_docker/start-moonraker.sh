#!/bin/bash
wait_file() {
  local file="$1"; shift
  local wait_seconds="${1:-10}"; shift # 10 seconds as default timeout

  until test $((wait_seconds--)) -eq 0 -o -e "$file" ; do sleep 1; done

  ((++wait_seconds))
}

klippy_uds=/tmp/klippy_uds
wait_file "$klippy_uds" 10 || {
  echo "klippy_uds domain socket file missing after waiting for $? seconds: '$klippy_uds' - check if klipper configured correctly and is running"
  exit 1
}
chown moonraker:moonraker /tmp/klippy_uds>>/logs/moonraker-shell.log
/moonraker/moonraker-env/bin/python /moonraker/moonraker/moonraker.py -l /logs/moonraker.log
