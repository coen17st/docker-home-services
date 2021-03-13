#!/bin/bash

day=`date '+%A'`
tar_name="${day}_prd-esphome.tar.gz"

# TAR.GZ THE DATA
tar -czvf /backups/${tar_name} /data/prd-esphome/config/ >> /var/log/cron.log 2>&1

# UPLOAD TO DROPBOX
curl -X POST https://content.dropboxapi.com/2/files/upload \
--header "Authorization: Bearer ${DROPBOX_ACCESS_TOKEN}" \
--header "Dropbox-API-Arg: {\"path\": \"/${tar_name}\",\"mode\": \"overwrite\",\"autorename\": true,\"mute\": false,\"strict_conflict\": false}" \
--header "Content-Type: application/octet-stream" \
--data-binary @/backups/${tar_name} | tee -a /var/log/cron.log

echo "$(date): executed script" >> /var/log/cron.log 2>&1