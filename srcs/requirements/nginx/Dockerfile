FROM alpine:3.22

RUN apk add --no-cache nginx openssl

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -sha256 -days 365 -newkey rsa:2048 \
	-out /etc/nginx/ssl/inception.crt \
	-keyout /etc/nginx/ssl/inception.key \
	-subj "/C=FI/ST=Uusimaa/L=Helsinki/O=HiveHelsinki/OU=Hive/CN=cwong.42.fr/UID=cwong"

COPY conf/nginx.conf /etc/nginx/http.d/default.conf

RUN mkdir -p /run/nginx

EXPOSE 443

#RUN mkdir -p /var/www/html
#RUN echo "<h1>NGINX is working perfectly!</h1>" > /var/www/html/index.html

CMD ["nginx", "-g", "daemon off;"]
