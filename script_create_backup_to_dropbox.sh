#!/bin/bash

# CHANGE THE VARIABLES BELOW (OPTIONAL)
color_green='\033[1;32m'
color_no='\033[0m'

clear

# FUNCTIONS 
prd-esphome-to-dropbox()
{
    # LOCAL VARIABLES CHANGE THESE
    local source_dir="prd-esphome/config"
    local container_name="prd-esphome-app"

    # LOCAL VARIABLES
    local backup_path_and_file="../backups/${container_name}.tar.gz"

    # ASK DROPBOX TOKEN

    if [ -z ${docker_home_services_backups_access_token+x} ]
    then
    printf "${color_green}Enter the Dropbox docker-home-services-backups app access token:${color_no}"
    read docker_home_services_backups_access_token
    export docker_home_services_backups_access_token=${docker_home_services_backups_access_token}
    printf "\n"
    fi

    #printf "${color_green}Enter the Dropbox docker-home-services-backups app access token:${color_no}"
    #read docker_home_services_backups_access_token
    #printf "\n"
    
    # STOP THE CONTAINER
    printf "${color_green}Stop docker container ${container_name}\n${color_no}"
    sudo docker stop ${container_name} > /dev/null 2>&1

    # WHEN CONTAINER IS STOPPED
    while sudo docker ps --filter "status=exited" | grep -q "${container_name}"
    do
        printf "${color_green}Docker container ${container_name} has status \"exited\"\n${color_no}"

        # TAR.GZ THE DATA
        sudo tar -czvf ${backup_path_and_file} ../docker-home-services/${source_dir}/

        # UPLOAD TO DROPBOX
        curl -X POST https://content.dropboxapi.com/2/files/upload \
        --header "Authorization: Bearer ${docker_home_services_backups_access_token}" \
        --header "Dropbox-API-Arg: {\"path\": \"/${container_name}.tar.gz\",\"mode\": \"overwrite\",\"autorename\": true,\"mute\": false,\"strict_conflict\": false}" \
        --header "Content-Type: application/octet-stream" \
        --data-binary @../backups/${container_name}.tar.gz

        break
    done        
}

prd-home-assistant-to-dropbox()
{
    # LOCAL VARIABLES CHANGE THESE
    local source_dir="prd-home-assistant/config"
    local container_name="prd-home-assistant-app"

    # LOCAL VARIABLES
    local backup_path_and_file="../backups/${container_name}.tar.gz"

    if [ -z ${docker_home_services_backups_access_token+x} ]
    then
    printf "${color_green}Enter the Dropbox docker-home-services-backups app access token:${color_no}"
    read docker_home_services_backups_access_token
    export docker_home_services_backups_access_token=${docker_home_services_backups_access_token}
    printf "\n"
    fi
    
    # STOP THE CONTAINER
    printf "${color_green}Stop docker container ${container_name}\n${color_no}"
    sudo docker stop ${container_name} > /dev/null 2>&1

    # WHEN CONTAINER IS STOPPED
    while sudo docker ps --filter "status=exited" | grep -q "${container_name}"
    do
        printf "${color_green}Docker container ${container_name} has status \"exited\"\n${color_no}"

        # TAR.GZ THE DATA
        sudo tar -czvf ${backup_path_and_file} ../docker-home-services/${source_dir}/

        # UPLOAD TO DROPBOX
        curl -X POST https://content.dropboxapi.com/2/files/upload \
        --header "Authorization: Bearer ${docker_home_services_backups_access_token}" \
        --header "Dropbox-API-Arg: {\"path\": \"/${container_name}.tar.gz\",\"mode\": \"overwrite\",\"autorename\": true,\"mute\": false,\"strict_conflict\": false}" \
        --header "Content-Type: application/octet-stream" \
        --data-binary @../backups/${container_name}.tar.gz

        break
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

# BACKUP HOME ASSISTANT
while true
do
printf "${color_green}"
read -r -p "Do you want to backup \"prd-home-assistant\" to your Dropbox [Y/n]" input
printf "${color_no}"
    case $input in
    [yY][eE][sS]|[yY])
        prd-home-assistant-to-dropbox
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