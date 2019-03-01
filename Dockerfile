FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends cron mysql-client python3-pip && \
    pip3 install awscli && \
    mkdir /backup

ENV CRON_TIME="0 0 * * *" \
    MYSQL_DB="--all-databases"

ADD run.sh /run.sh
VOLUME ["/backup"]

CMD ["/run.sh"]