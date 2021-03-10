#!/bin/bash

# CHANGE THE VARIABLES BELOW (OPTIONAL)
color_green='\033[1;32m'
color_no='\033[0m'

# FUNCTION
prd-esphome-to-dropbox()
{
    # LOCAL VARIABLES
    local service_dir="prd-esphome"
    local container_name="${service_dir}-app"

    # STOP THE CONTAINER
    printf "${color_green}Stop docker container ${container_name}\n${color_no}"
    sudo docker stop ${container_name} > /dev/null 2>&1
    # WHEN CONTAINER IS STOPPED
    while sudo docker ps --filter "status=exited" | grep -q "${container_name}"
    do
        printf "${color_green}Docker container ${container_name} has status \"exited\"\n${color_no}"
        sleep 2
        # TAR.GZ THE DATA
        cd ..
        cd backups
        echo ${PWD}
        sudo tar -czvf ${service_dir}.tar.gz ../docker-home-services/${service_dir}/
    done        
}


# BACKUP ESPHOME
while true
do
printf "${color_green}"
read -r -p "Do you want to backup \"prd-esphome\" to your Dropbox [Y/n]" input
printf "${color_no}"
    case $input in
    [yY][eE][sS]|[yY])
        if [ -z ${prd_esphome_dropbox_token+x} ]
        then
        printf "${color_green}Enter the \"prd-esphome\" Dropbox app token:${color_no}"
        read prd_esphome_dropbox_token
        printf "\n"
        fi
        prd-esphome-to-dropbox
    break
    ;;
    [nN][oO]|[nN])
        printf "\n"
    break
    ;;
    *)
    echo "Invalid input..."
    ;;
    esac
    done