#!/bin/bash
su klipper -c "/klipper/klippy-env/bin/python /klipper/klippy/klippy.py /klipper/config/printer.cfg -l /logs/klipper.log -a /tmp/klippy_uds"
