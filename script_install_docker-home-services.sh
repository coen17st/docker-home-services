#!/bin/bash
# DON'T CHANGE ANYTHING BELOW
ip4=$(hostname -I | cut -d' ' -f1)
date=`date '+%Y-%m-%d %H:%M:%S'`
color_blue='\033[1;34m'
color_green='\033[1;32m'
color_no='\033[0m'

clear
printf "${color_blue}"
cat << "EOF"
 _____             _               _    _                         _____                 _               
|  __ \           | |             | |  | |                       / ____|               (_)              
| |  | | ___   ___| | _____ _ __  | |__| | ___  _ __ ___   ___  | (___   ___ _ ____   ___  ___ ___  ___ 
| |  | |/ _ \ / __| |/ / _ \ '__| |  __  |/ _ \| '_ ` _ \ / _ \  \___ \ / _ \ '__\ \ / / |/ __/ _ \/ __|
| |__| | (_) | (__|   <  __/ |    | |  | | (_) | | | | | |  __/  ____) |  __/ |   \ V /| | (_|  __/\__ \
|_____/ \___/ \___|_|\_\___|_|    |_|  |_|\___/|_| |_| |_|\___| |_____/ \___|_|    \_/ |_|\___\___||___/
==== written by Coen Stam ===================================================================================
EOF
cat << EOF

This script will install the following software on hostmachine:
- Docker
- Docker Compose

and the following images on Docker:
- Portainer
- Adminer
- MariaDB
- Plex
- Node-RED
- Home Assistant
- Eclipse Mosquitto
- Bitwarden
- DSMR-Reader
=============================================================================================================
EOF

while true
do
printf "${color_green}"
read -r -p "Do you wish to update and upgrade the system? [Y/n]" input
printf "${color_no}"
    case $input in
    [yY][eE][sS]|[yY])
        printf "${color_green}Update system\n${color_no}"
        sudo apt update -y \
        && sudo apt upgrade -y
        printf "\n"
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


# CREATE FOLDERS
sudo mkdir -p ../backups/
sudo mkdir -p ../media/


# CHECK IF DOCKER IS INSTALLED
docker --version > /dev/null 2>&1
if [ $? -ne 0 ]
then
# IF NOT, DOWNLOAD AND INSTALL DOCKER
printf "${color_green}Install docker\n${color_no}"
sudo apt install docker.io -y
# START/ENABLE DOCKER
sudo systemctl enable --now docker
# SET USER PREVLILEGES
sudo groupadd docker
sudo usermod -aG docker ${USER}
# CHECK DOCKER VERSION
docker --version
printf "\n"
else
# IF DOCKER ALREADY IS INSTALLED SHOW DOCKER VERSION
dockerversion=$(docker --version)
printf "${color_green}${dockerversion} is installed\n\n${color_no}"
fi


# CHECK IF DOCKER-COMPOSE IS INSTALLED
docker-compose --version > /dev/null 2>&1
if [ $? -ne 0 ]
then
# IF NOT, DOWNLOAD AND INSTALL DOCKER-COMPOSE
printf "${color_green}Installing Docker Compose\n${color_no}"
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# SHOW DOCKER-COMPOSE VERSION
docker-compose --version
else
dockercomposeversion=$(docker-compose --version)
printf "${color_green}${dockercomposeversion} is installed\n\n${color_no}"
fi


# SET GIT CONFIG USER
if [ ! -f "${HOME}/.gitconfig" ] 
then
printf "${color_green}Enter github user email:${color_no}"
read user_email
git config --global user.email "${user_email}"
printf "${color_green}Enter github user name:${color_no}"
read user_name
git config --global user.name "${user_name}"
printf "\n"
fi


# ADGUARD HOME
if [ ! -f "./prd-adguard-home/.env" ]; 
then
# CREATE .ENV FILE
printf "${color_green}No .env file found for Adguard Home, a default file will be created. If credentials are required, you will be asked to enter them.${color_no}"
cp ./prd-adguard-home/.env.example ./prd-adguard-home/.env
printf "\n\n"
fi
# FREE PORT 53 FOR ADGUARD
if grep -qFx "#DNSStubListener=yes" /etc/systemd/resolved.conf
then
sudo sed -i "s|#DNSStubListener=yes|DNSStubListener=no|g" /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved
printf "${color_green}Opend port 53 for adguardhome\n\n${color_no}"
    if [ $? -ne 0 ]
    then
    printf "${color_green}Failed to change DNSStubListener\n\n${color_no}"
    fi
fi


# DSMRREADER
if [ ! -f "./prd-dsmr-reader/.env" ]; 
then
# CREATE .ENV FILE
printf "${color_green}No .env file found for DSMR-Reader, a default file will be created. If credentials are required, you will be asked to enter them.${color_no}"
cp ./prd-dsmr-reader/.env.example ./prd-dsmr-reader/.env
printf "\n\n"
fi
# ASK FOR VARIABLES TO PUT THESE INTO THE .ENV FILE
# DSMRREADER POSTGRES USER
if grep -qFx "DSMRREADER_POSTGRES_USER=" ./prd-dsmr-reader/.env
then
printf "${color_green}Enter a POSTGRES USER for the DSMR-Reader database:${color_no}"
read dsmrreader_postgres_user
sudo sed -i "s/DSMRREADER_POSTGRES_USER=/DSMRREADER_POSTGRES_USER=$dsmrreader_postgres_user/" ./prd-dsmr-reader/.env
fi
# DSMRREADER POSTGRES PASSWORD
if grep -qFx "DSMRREADER_POSTGRES_PASSWORD=" ./prd-dsmr-reader/.env
then
printf "${color_green}Enter a POSTGRES PASSWORD for the DSMR-Reader database:${color_no}"
read -s dsmrreader_postgres_password
sudo sed -i "s/DSMRREADER_POSTGRES_PASSWORD=/DSMRREADER_POSTGRES_PASSWORD=$dsmrreader_postgres_password/" ./prd-dsmr-reader/.env
printf "\n"
fi
# DSMRREADER ADMIN_USER
if grep -qFx "DSMRREADER_ADMIN_USER=" ./prd-dsmr-reader/.env
then
printf "${color_green}Enter a username for the DSMR-Reader webinterface:${color_no}"
read dsmrreader_admin_user
sudo sed -i "s/DSMRREADER_ADMIN_USER=/DSMRREADER_ADMIN_USER=$dsmrreader_admin_user/" ./prd-dsmr-reader/.env
fi
# DSMRREADER ADMIN PASSWORD
if grep -qFx "DSMRREADER_ADMIN_PASSWORD=" ./prd-dsmr-reader/.env
then
printf "${color_green}Enter a password for the DSMR-Reader webinterface:${color_no}"
read -s dsmrreader_admin_password
sudo sed -i "s/DSMRREADER_ADMIN_PASSWORD=/DSMRREADER_ADMIN_PASSWORD=$dsmrreader_admin_password/" ./prd-dsmr-reader/.env
printf "\n"
fi


# ESPHOME
if [ ! -f "./prd-esphome/.env" ]; 
then
# CREATE .ENV FILE
printf "${color_green}No .env file found for ESPhome, a default file will be created. If credentials are required, you will be asked to enter them.${color_no}"
cp ./prd-esphome/.env.example ./prd-esphome/.env
printf "\n\n"
fi
# ASK FOR VARIABLES TO PUT THESE INTO THE .ENV FILE
# USER
if grep -qFx "USERNAME=" ./prd-esphome/.env
then
printf "${color_green}Enter a USERNAME for the ESPhome webpage:${color_no}"
read esphome_username
sudo sed -i "s/USERNAME=/USERNAME=$esphome_username/" ./prd-esphome/.env
fi
# PASSWORD
if grep -qFx "PASSWORD=" ./prd-esphome/.env
then
printf "${color_green}Enter a PASSWORD for the ESPhome webpage:${color_no}"
read -s esphome_password
sudo sed -i "s/PASSWORD=/PASSWORD=$esphome_password/" ./prd-esphome/.env
printf "\n\n"
fi


# HOME ASSISTANT
if [ ! -f "./prd-home-assistant/.env" ]; 
then
# CREATE .ENV FILE
printf "${color_green}No .env file found for Home Assistant, a default file will be created. If credentials are required, you will be asked to enter them.${color_no}"
cp ./prd-home-assistant/.env.example ./prd-home-assistant/.env
printf "\n\n"
fi
# ASK FOR VARIABLES TO PUT THESE INTO THE .ENV FILE
# MYSQL USER
if grep -qFx "HOME_ASSISTANT_MYSQL_USER=" ./prd-home-assistant/.env
then
printf "${color_green}Enter a MYSQL USER for the Home Assistant database:${color_no}"
read home_assistant_mysql_user
sudo sed -i "s/HOME_ASSISTANT_MYSQL_USER=/HOME_ASSISTANT_MYSQL_USER=$home_assistant_mysql_user/" ./prd-home-assistant/.env
fi
# MYSQL PASSWORD
if grep -qFx "HOME_ASSISTANT_MYSQL_PASSWORD=" ./prd-home-assistant/.env
then
printf "${color_green}Enter a MYSQL password for the Home Assistant database:${color_no}"
read -s home_assistant_mysql_password
sudo sed -i "s/HOME_ASSISTANT_MYSQL_PASSWORD=/HOME_ASSISTANT_MYSQL_PASSWORD=$home_assistant_mysql_password/" ./prd-home-assistant/.env
printf "\n"
fi
# MYSQL ROOT PASSWORD
if grep -qFx "HOME_ASSISTANT_MYSQL_ROOT_PASSWORD=" ./prd-home-assistant/.env
then
printf "${color_green}Enter a MYSQL root password for the Home Assistant database:${color_no}"
read -s home_assistant_mysql_root_password
sudo sed -i "s/HOME_ASSISTANT_MYSQL_ROOT_PASSWORD=/HOME_ASSISTANT_MYSQL_ROOT_PASSWORD=$home_assistant_mysql_root_password/" ./prd-home-assistant/.env
printf "\n"
fi


# MOSQUITTO
if [ ! -f "./prd-mosquitto/.env" ]; 
then
# CREATE .ENV FILE
printf "${color_green}No .env file found for Mosquitto, a default file will be created. If credentials are required, you will be asked to enter them.${color_no}"
cp ./prd-mosquitto/.env.example ./prd-mosquitto/.env
printf "\n\n"
fi


# NODE-RED
if [ ! -f "./prd-node-red/.env" ]; 
then
# CREATE .ENV FILE
printf "${color_green}No .env file found for Node-RED, a default file will be created. If credentials are required, you will be asked to enter them.${color_no}"
cp ./prd-node-red/.env.example ./prd-node-red/.env
printf "\n\n"
fi


# NGINX-CERTBOT
while true
do
# ASK IF ROUTER PORTS ARE SET UP CORRECTLY
printf "${color_green}"
read -r -p "Check if port 443 and 80 are open to ${ip4} in your router settings. Do you want to start the nginx reverse proxy letsencrypt script? [Y/n]" input
printf "${color_no}"
    case $input in
    [yY][eE][sS]|[yY])
        printf "${color_green}Start bash script for nginx-certbot\n\n${color_no}"
        cd prd-nginx-certbot
        sudo ./init-letsencrypt.sh
        cd ..
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


# PLEX
if [ ! -f "./prd-plex/.env" ]; 
then
# CREATE .ENV FILE
printf "${color_green}No .env file found for plex, a default file will be created. If credentials are required, you will be asked to enter them.${color_no}"
cp ./prd-plex/.env.example ./prd-plex/.env
printf "\n\n"
fi
# ASK FOR VARIABLES TO PUT THESE INTO THE .ENV FILE
# PLEX CLAIM TOKEN
if grep -qFx "PLEX_CLAIMTOKEN=" ./prd-plex/.env
then
printf "${color_green}Enter your Plex Claimtoken, you can obtain a claim token to login your server to your plex account by visiting https://www.plex.tv/claim ${color_no}"
printf "${color_green}\nPLEX CLAIMTOKEN:${color_no}"
read plex_claimtoken
sudo sed -i "s/PLEX_CLAIMTOKEN=/PLEX_CLAIMTOKEN=$plex_claimtoken/" ./prd-plex/.env
printf "\n"
fi


# TRANSMISSION-OPENVPN
if [ ! -f "./prd-transmission-openvpn/.env" ]; 
then
# CREATE .ENV FILE
printf "${color_green}No .env file found for transmission-openvpn, a default file will be created. If credentials are required, you will be asked to enter them.${color_no}"
cp ./prd-transmission-openvpn/.env.example ./prd-transmission-openvpn/.env
printf "\n\n"
fi
# ASK FOR VARIABLES TO PUT THESE INTO THE .ENV FILE
# OPENVPN USERNAME
if grep -qFx "OPENVPN_USERNAME=" ./prd-transmission-openvpn/.env
then
printf "${color_green}Enter your NORDVPN username:${color_no}"
read openvpn_username
sudo sed -i "s/OPENVPN_USERNAME=/OPENVPN_USERNAME=$openvpn_username/" ./prd-transmission-openvpn/.env
fi
# OPENVPN PASSWORD
if grep -qFx "OPENVPN_PASSWORD=" ./prd-transmission-openvpn/.env
then
printf "${color_green}Enter your NORDVPN password:${color_no}"
read -s openvpn_password
sudo sed -i "s/OPENVPN_PASSWORD=/OPENVPN_PASSWORD=$openvpn_password/" ./prd-transmission-openvpn/.env
printf "\n\n"
fi


# DOCKER COMPOSE UP
while true
do
printf "${color_green}"
read -r -p "Do you wish to (re)create and start the docker containers? [Y/n]" input
printf "${color_no}"
    case $input in
    [yY][eE][sS]|[yY])
        printf "${color_green}Starting the docker containers\n${color_no}"
        
        sudo docker-compose -f ./prd-adguard-home/docker-compose.yml up -d  
        sudo docker-compose -f ./prd-dsmr-reader/docker-compose.yml up -d
        sudo docker-compose -f ./prd-esphome/docker-compose.yml up -d
        sudo docker-compose -f ./prd-home-assistant/docker-compose.yml up -d
        sudo docker-compose -f ./prd-mosquitto/docker-compose.yml up -d
        sudo docker-compose -f ./prd-nginx-certbot/docker-compose.yml up -d
        sudo docker-compose -f ./prd-node-red/docker-compose.yml up -d
        sudo docker-compose -f ./prd-plex/docker-compose.yml up -d
        sudo docker-compose -f ./prd-portainer/docker-compose.yml up -d
        sudo docker-compose -f ./prd-transmission-openvpn/docker-compose.yml up -d

        printf "\n"
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


# ------------ LAST COMMAND --------------
# REMOVE ALL IMAGES NOT REFERENCED BY ANY CONTAINER
printf "${color_green}Remove all images not referenced by any container\n\n${color_no}"
sudo docker image prune --all --force