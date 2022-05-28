FROM nginx:1.22
COPY nginx/ /etc/nginx/
RUN rm /etc/nginx/conf.d/default.conf
COPY mainsail /usr/share/nginx/html
EXPOSE 80
