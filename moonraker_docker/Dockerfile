FROM python:3
EXPOSE 7125
RUN apt update && apt install -y python-virtualenv virtualenv 
RUN mkdir /moonraker
WORKDIR /moonraker
COPY moonraker ./
RUN virtualenv -p python3 /moonraker/moonraker-env 
RUN /moonraker/moonraker-env/bin/pip install -r /moonraker/scripts/moonraker-requirements.txt
COPY moonraker.conf /moonraker
COPY start-moonraker.sh /moonraker 
USER root
ENTRYPOINT ["/moonraker/start-moonraker.sh"]
