# mysql-backup-s3

This image runs mysqldump to backup data using cronjob to folder `/backup` and then upload to S3.

## Parameters

    MYSQL_HOST            the host/ip of your mysql database
    MYSQL_PORT            the port number of your mysql database
    MYSQL_USER            the username of your mysql database
    MYSQL_PASS            the password of your mysql database
    MYSQL_DB              the database name to dump. Default: `--all-databases`
    AWS_ACCESS_KEY_ID     the AWS access key
    AWS_SECRET_ACCESS_KEY the AWS secret key
    S3_BUCKET             the S3 bucket to upload into
    S3_REGION             the S3 bucket region
    S3_PREFIX             the S3 file prefix
    CRON_TIME             the interval of cron job to run mysqldump. `0 0 * * *` by default, which is every day at 00:00

## Run

```
docker run -d --network="XXX" --env-file="XXX.env" fire015/mysql-backup-s3
```