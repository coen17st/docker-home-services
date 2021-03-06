#!/bin/bash
# DON'T CHANGE ANYTHING BELOW
sleepseconds="2"
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


# CREATE .ENV FILES
# ADGUARD HOME
if [ ! -f "./prd-adguard-home/.env" ]; 
then
printf "${color_green}Creating default .env files${color_no}"
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


# CREATE .ENV FILES
# HOME ASSISTANT
if [ ! -f "./prd-home-assistant/.env" ]; 
then
printf "${color_green}Creating default .env files${color_no}"
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


# CREATE .ENV FILES
# MOSQUITTO
if [ ! -f "./prd-mosquitto/.env" ]; 
then
printf "${color_green}Creating default .env files${color_no}"
cp ./prd-mosquitto/.env.example ./prd-mosquitto/.env
printf "\n\n"
fi


# PLEX CLAIM TOKEN
if [ ! -f "./prd-plex/.env" ]; 
then
printf "${color_green}Creating default .env files${color_no}"
cp ./prd-plex/.env.example ./prd-plex/.env
printf "\n\n"
fi
if grep -qFx "PLEX_CLAIMTOKEN=" ./prd-plex/.env
then
printf "${color_green}Enter your Plex Claimtoken, you can obtain a claim token to login your server to your plex account by visiting https://www.plex.tv/claim ${color_no}"
printf "${color_green}\nPLEX CLAIMTOKEN:${color_no}"
read plex_claimtoken
sudo sed -i "s/PLEX_CLAIMTOKEN=/PLEX_CLAIMTOKEN=$plex_claimtoken/" ./prd-plex/.env
printf "\n"
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
        sudo docker-compose -f ./prd-portainer/docker-compose.yml up -d
        sudo docker-compose -f ./prd-adguard-home/docker-compose.yml up -d  
        sudo docker-compose -f ./prd-home-assistant/docker-compose.yml up -d
        sudo docker-compose -f ./prd-mosquitto/docker-compose.yml up -d
        sudo docker-compose -f ./prd-plex/docker-compose.yml up -d
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

