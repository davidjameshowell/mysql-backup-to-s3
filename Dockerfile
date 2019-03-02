FROM ubuntu:18.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends cron mysql-client python3-pip python3-setuptools python3-wheel && \
    pip3 install awscli && \
    mkdir /backup

ENV CRON_TIME="0 0 * * *"

ADD run.sh /run.sh

CMD ["/run.sh"]