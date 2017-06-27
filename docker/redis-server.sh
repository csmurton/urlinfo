#!/bin/sh
exec /sbin/setuser redis /usr/bin/redis-server >> /var/log/redis-server.log 2>&1
