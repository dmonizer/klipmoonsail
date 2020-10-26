#!/bin/sh
nginx &
cd /3d_print
sudo -u klipper ./moonraker-env/bin/python moonraker/moonraker.py -l logs/moonraker.log &
sudo -u klipper ./klippy-env/bin/python klipper/klippy/klippy.py klipper_config/printer.cfg -l logs/klipper.log -a /tmp/klippy_uds &
sleep 1
sudo -u klipper tail -f logs/*

