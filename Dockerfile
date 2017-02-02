FROM debian:jessie
MAINTAINER Yohann LOEFFLER <loeffler.yohann@gmail.com>

RUN apt-get update && \
    apt-get install -y --no-install-recommends cron mysql-client && \
    apt-get install -y cron && \
    mkdir /backup

ENV CRON_TIME="0 0 * * *" \
    MYSQL_DB="--all-databases"
ADD run.sh /run.sh
VOLUME ["/backup"]

CMD ["/run.sh"]
