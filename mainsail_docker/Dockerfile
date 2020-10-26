FROM alpine:latest
USER root
RUN apk add \
 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main \
 --repository=http://dl-cdn.alpinelinux.org/alpine/v3.10/main \
 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
 wget sudo unzip git \
 dfu-util nginx \
 py2-virtualenv python2-dev libffi-dev g++ make \
 ncurses-dev \
 libusb-dev \
 avrdude gcc-avr binutils-avr avr-libc \
 stm32flash dfu-util newlib-arm-none-eabi \
 libusb \
 python3-dev && rm -rf /var/cache/apk/*


# --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
# --repository=http://dl-cdn.alpinelinux.org/alpine/edge/main

# RUN 
RUN adduser -D -h /3d_print klipper
WORKDIR /3d_print
USER root
COPY nginx/upstreams.conf /etc/nginx/conf.d/
COPY nginx/common_vars.conf /etc/nginx/conf.d/
COPY nginx/mainsail.conf /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/mainsail.conf /etc/nginx/conf.d/mainsail.conf && rm /etc/nginx/conf.d/default.conf &&\
 mkdir /run/nginx

USER klipper
#RUN git clone https://github.com/KevinOConnor/klipper.git
#RUN git clone --verbose https://github.com/Arksine/moonraker.gitc
COPY git/klipper .
COPY git/moonraker .
ENV PYTHON2DIR="/3d_print/klippy-env"
ENV PYTHON3DIR="/3d_print/moonraker-env"
ENV KLIPPER_SRCDIR="/3d_print/klipper"
ENV MOONRAKER_SRCDIR="/3d_print/moonraker"
#RUN virtualenv -p python2 ${PYTHON2DIR}
#RUN ${PYTHON2DIR}/bin/pip install -r ${KLIPPER_SRCDIR}/scripts/klippy-requirements.txt
#RUN virtualenv -p python3 ${PYTHON3DIR}
#RUN ${PYTHON3DIR}/bin/pip install -r ${MOONRAKER_SRCDIR}/scripts/moonraker-requirements.txt
#RUN mv moonraker/moonraker/* moonraker/

#RUN mkdir -p klipper_config && mkdir -p sdcard && mkdir -p logs && mkdir /3d_print/mainsail
#COPY moonraker.conf /3d_print
#RUN wget https://github.com/meteyou/mainsail/releases/download/v0.2.4/mainsail-beta-0.2.4.zip
#COPY mainsail-beta-0.2.4.zip .
#RUN mv mainsail-beta-0.2.4.zip mainsail.zip && \
# unzip mainsail.zip -d mainsail/ && rm mainsail.zip

#USER root
#COPY start-klipmoonsail.sh /3d_print 
#RUN chmod +x start-klipmoonsail.sh
#RUN chown klipper:klipper *
#USER root
#CMD ["/sbin/init", "/bin/ash"]
#ENTRYPOINT ["/3d_print/start-klipmoonsail.sh"]
ENTRYPOINT ["/bin/ash"]
