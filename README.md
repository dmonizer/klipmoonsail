# klipmoonsail

intended to build and run dockerized klipper, moonraker and moonsail on raspi (which has direct usb connection to your 3d printer).

edit buildstart.sh script and make sure your printer device is set as PRINTER_DEVICE. put your klipper config to runtime/config as printer.cfg

run ./buildstart.sh which will clone klipper and moonraker and download mainsaid release 0.2.6, builds docker images and run klipper for the first time interactively, so you can configure and flash the printer according to klipper docs (up to flashing)
edit runstart.sh and comment out docker build lines and klipper first run line, save and run it again.
now klipper, moonraker and mainsail are running in docker (hopefully) and you can connect to your raspi:8080 with web browser.

There is currently an issue that moonraker cannot connect to klippy, altho both can see the UDS - ideas/PRs welcome.
