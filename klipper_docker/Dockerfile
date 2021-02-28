FROM python:2
USER root
RUN apt update
RUN apt install -y\
 python-virtualenv virtualenv python-dev libffi-dev build-essential \
 libncurses-dev \
 libusb-dev \
 avrdude gcc-avr binutils-avr avr-libc \
 stm32flash libnewlib-arm-none-eabi \
 gcc-arm-none-eabi binutils-arm-none-eabi libusb-1.0

RUN mkdir /klipper
ARG UID
ARG GID
RUN groupadd -g ${GID} 3dprinters
RUN useradd klipper --base-dir / -u ${UID} -g ${GID}
RUN chown klipper:3dprinters /klipper
WORKDIR /klipper
USER klipper
COPY klipper ./
ENV PYTHON2DIR="/klipper/klippy-env"
ENV KLIPPER_SRCDIR="/klipper/"

RUN virtualenv -p python2 ${PYTHON2DIR}
RUN ${PYTHON2DIR}/bin/pip install -r ${KLIPPER_SRCDIR}/scripts/klippy-requirements.txt

COPY start-klipper.sh .
USER root 
RUN addgroup klipper dialout
RUN chown -R klipper:3dprinters .
RUN chmod +x start-klipper.sh
CMD ["/klipper/start-klipper.sh"]
