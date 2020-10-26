FROM alpine:latest
USER root
RUN apk add \
 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main \
 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
 sudo  \
 dfu-util \
 libffi-dev g++ make \
 ncurses-dev \
 libusb-dev \
 avrdude gcc-avr binutils-avr avr-libc \
 stm32flash dfu-util newlib-arm-none-eabi \
 libusb \
 python2 py3-virtualenv python2-dev \
 && rm -rf /var/cache/apk/*

RUN adduser -D -h /klipper klipper
WORKDIR /klipper
USER root
#RUN git clone https://github.com/KevinOConnor/klipper.git
COPY klipper ./
ENV PYTHON2DIR="/klipper/klippy-env"
ENV KLIPPER_SRCDIR="/klipper/klipper"

RUN chown klipper:klipper *
USER klipper
RUN virtualenv -p python2 ${PYTHON2DIR}
RUN ${PYTHON2DIR}/bin/pip install -r ${KLIPPER_SRCDIR}/scripts/klippy-requirements.txt

#RUN ipper_config && mkdir -p sdcard 
#COPY moonraker.conf /3d_print
#RUN wget https://github.com/meteyou/mainsail/releases/download/v0.2.4/mainsail-beta-0.2.4.zip
#COPY mainsail-beta-0.2.4.zip .
#RUN mv mainsail-beta-0.2.4.zip mainsail.zip && \
# unzip mainsail.zip -d mainsail/ && rm mainsail.zip

#USER root
COPY start-kliper.sh . 
RUN chmod +x start-klipper.sh
#RUN chown klipper:klipper *
#USER root
#CMD ["/sbin/init", "/bin/ash"]
ENTRYPOINT ["/3d_print/start-klipmoonsail.sh"]
#ENTRYPOINT ["/bin/ash"]
