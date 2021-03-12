FROM ubuntu:latest

# INSTALL CRON
RUN apt-get update \
    && apt-get install cron -y \
    && apt-get clean \
    && apt-get install iputils-ping -y

RUN mkdir -p /data/

# ADD CRONTAB FILE IN THE CRON DIRECTORY
ADD /data/crontab /etc/cron.d/simple-cron

# ADD SHELL SCRIPT AND GRANT EXECUTION RIGHTS
ADD /data/script.sh /data/script.sh
RUN chmod +x /data/script.sh

# GIVE EXECUTION RIGHTS ON THE CRON JOB
RUN chmod 0644 /etc/cron.d/simple-cron

# CREATE THE LOG FILE TO BE ABLE TO RUN TAIL
RUN touch /var/log/cron.log

# RUN THE COMMAND ON CONTAINER STARTUP
CMD cron && tail -f /var/log/cron.log