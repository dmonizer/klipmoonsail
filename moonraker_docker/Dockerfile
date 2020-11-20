FROM python:3
EXPOSE 7125
RUN apt update && apt install -y python-virtualenv virtualenv 
ARG UID
ARG GID
RUN groupadd -g ${GID} 3dprinters
RUN useradd moonraker --base-dir / -u ${UID} -g ${GID}
RUN mkdir /moonraker
RUN chown moonraker:3dprinters /moonraker
WORKDIR /moonraker
COPY moonraker ./
RUN virtualenv -p python3 /moonraker/moonraker-env 
RUN /moonraker/moonraker-env/bin/pip install -r /moonraker/scripts/moonraker-requirements.txt
COPY moonraker.conf /moonraker
COPY start-moonraker.sh /moonraker 
RUN chown -R moonraker:3dprinters .
USER moonraker
ENTRYPOINT ["/moonraker/start-moonraker.sh"]
