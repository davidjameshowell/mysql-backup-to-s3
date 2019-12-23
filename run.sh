#!/bin/bash
[ -z "${MYSQL_HOST}" ] && { echo "=> MYSQL_HOST cannot be empty" && exit 1; }
[ -z "${MYSQL_PORT}" ] && { echo "=> MYSQL_PORT cannot be empty" && exit 1; }
[ -z "${MYSQL_USER}" ] && { echo "=> MYSQL_USER cannot be empty" && exit 1; }
[ -z "${MYSQL_PASS}" ] && { echo "=> MYSQL_PASS cannot be empty" && exit 1; }
[ -z "${MYSQL_DB}" ] && { echo "=> MYSQL_DB cannot be empty" && exit 1; }
[ -z "${S3_BUCKET}" ] && { echo "=> S3_BUCKET cannot be empty" && exit 1; }
[ -z "${S3_PREFIX}" ] && { echo "=> S3_PREFIX cannot be empty" && exit 1; }
[ -z "${S3_REGION}" ] && { echo "=> S3_REGION cannot be empty" && exit 1; }
[ -z "${AWS_ACCESS_KEY_ID}" ] && { echo "=> AWS_ACCESS_KEY_ID cannot be empty" && exit 1; }
[ -z "${AWS_SECRET_ACCESS_KEY}" ] && { echo "=> AWS_SECRET_ACCESS_KEY cannot be empty" && exit 1; }
[ -z "${HEALTHCHECK_IO_GUID}" ] && { echo "=> HEALTHCHECK_IO_GUID cannot be empty" && exit 1; }

echo "=> Creating backup script"
rm -f /backup.sh
env > /etc/environment
cat <<EOF >> /backup.sh
#!/bin/bash
BACKUP_NAME=\${MYSQL_DB}-\$(date +\%Y-\%m-\%d-\%H-\%M-\%S).sql
BACKUP_CMD="mysqldump -h\${MYSQL_HOST} -P\${MYSQL_PORT} -u\${MYSQL_USER} -p\${MYSQL_PASS} --databases \${MYSQL_DB}"
cd /backup

echo "=> Backup started: \${BACKUP_NAME}"
if \${BACKUP_CMD} > \${BACKUP_NAME} ;then
    if [ "\${RESTORE_BACKUP_TO_LIVE_MYSQL_SERVER}" = "true" ];then
        # Import into Bitwarden Isolated Slave
        mysql --binary-mode=1 -h\${MYSQL_RESTORE_HOST} -P\${MYSQL_RESTORE_PORT} -u\${MYSQL_RESTORE_USER} -p\${MYSQL_RESTORE_PASS} \${MYSQL_RESTORE_DB} < \${BACKUP_NAME}
        echo 'Successfully imported into Live Host on \${MYSQL_RESTORE_HOST}'
    fi
    gzip -9 \${BACKUP_NAME}
    /usr/local/bin/aws s3 --region \${S3_REGION} cp \${BACKUP_NAME}.gz s3://\${S3_BUCKET}/\${S3_PREFIX}/\${BACKUP_NAME}.gz
    rm -rf \${BACKUP_NAME}.gz
    curl --retry 3 https://hc-ping.com/"${HEALTHCHECK_IO_GUID}"
    echo "   Backup succeeded"
else
    echo "   Backup failed"
    curl --retry 3 https://hc-ping.com/"${HEALTHCHECK_IO_GUID}"/fail
    rm -rf \${BACKUP_NAME}
fi
echo "=> Backup done"
EOF
chmod +x /backup.sh

echo "${CRON_TIME} /bin/bash /backup.sh >> /proc/1/fd/1 2>/proc/1/fd/2" > /crontab.conf
crontab /crontab.conf
echo "=> Running cron job"
exec cron -f

