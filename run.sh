#!/bin/bash -xe

env -
export $(cat /.env | xargs)

DATE=$(date +%F)
EXPIRE_DATE=$(date -d "-$RDS_RETENTION days" +%s)

aws rds create-db-snapshot --db-instance-identifier $RDS_ID --db-snapshot-identifier "$RDS_ID-$DATE"

EXIPRED=$(aws rds describe-db-snapshots | jq -rC '.DBSnapshots[] | select(.DBInstanceIdentifier==env.RDS_ID) | select((.SnapshotCreateTime|strptime("%Y-%m-%dT%H:%M:%S.%NZ")|mktime) < (env.EXPIRE_DATE|tonumber)) | .DBSnapshotIdentifier')

for X in $EXIPRED; do
  aws rds delete-db-snapshot --db-snapshot-identifier "$X"
done
