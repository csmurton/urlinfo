FROM phusion/baseimage:0.9.22
CMD ["/sbin/my_init"]
WORKDIR /usr/local/urlinfo
COPY node/ /usr/local/urlinfo
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y -q install nodejs=4.2.6~dfsg-1ubuntu4 redis-server=2:3.0.6-1
RUN mkdir /etc/service/redis-server
COPY docker/redis-server.sh /etc/service/redis-server/run
RUN chmod +x /etc/service/redis-server/run
RUN mkdir /etc/service/urlinfo
COPY docker/urlinfo.sh /etc/service/urlinfo/run
RUN chmod +x /etc/service/urlinfo/run
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EXPOSE 5000
