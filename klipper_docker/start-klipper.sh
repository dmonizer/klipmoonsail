#!/bin/sh
chmod 777 /logs
touch /logs/klipper.log
chmod 777 /logs/klipper.log
/klipper/klippy-env/bin/python /klipper/klippy/klippy.py /klipper/config/printer.cfg -l /logs/klipper.log -a /tmp/klippy_uds
