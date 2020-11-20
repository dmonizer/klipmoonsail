# klipmoonsail

intended to build and run dockerized klipper, moonraker and moonsail on raspi (which has direct usb connection to your 3d printer).

1) edit buildstart.sh script and make sure your printer device is set as PRINTER_DEVICE. 
2) put your klipper config to runtime/config as printer.cfg
3) run ./buildstart.sh which will clone klipper and moonraker and download mainsail release 0.2.6, builds docker images and run klipper for the first time interactively, so you can configure and flash the printer according to klipper docs (up to flashing)
4) edit runstart.sh and comment out docker build lines and klipper first run line, save and run it again when needed.

now klipper, moonraker and mainsail are running in docker (hopefully) and you can connect to your raspi:8080 with web browser.

to stop, use "docker stop klipper moonraker mainsail"
