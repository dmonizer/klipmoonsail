FROM alpine:latest
USER root
RUN apk add \
 musl py3-virtualenv python3-dev  && rm -rf /var/cache/apk/*


RUN adduser -D -h /moonraker moonraker
WORKDIR /moonraker
#USER root
#COPY nginx/upstreams.conf /etc/nginx/conf.d/
#COPY nginx/common_vars.conf /etc/nginx/conf.d/
#COPY nginx/mainsail.conf /etc/nginx/sites-available/
#RUN ln -s /etc/nginx/sites-available/mainsail.conf /etc/nginx/conf.d/mainsail.conf && rm /etc/nginx/conf.d/default.conf &&\
# mkdir /run/nginx

USER moonraker
#RUN git clone --verbose https://github.com/Arksine/moonraker.gitc
COPY moonraker ./moonraker
ENV PYTHON3DIR="/moonraker/moonraker-env"
ENV MOONRAKER_SRCDIR="/moonraker/moonraker"
RUN virtualenv -p python3 ${PYTHON3DIR}
RUN ${PYTHON3DIR}/bin/pip install -r ${MOONRAKER_SRCDIR}/scripts/moonraker-requirements.txt
#RUN mv moonraker/moonraker/ moonraker/

COPY moonraker.conf /moonraker

#USER root
COPY start-moonraker.sh /moonraker 
#RUN chmod +x start-moonraker.sh
#iRUN chown moonraker:moonraker *
#USER root
#CMD ["/sbin/init", "/bin/ash"]
USER moonraker
ENTRYPOINT ["/moonraker/start-moonraker.sh"]
#ENTRYPOINT ["/bin/ash"]
