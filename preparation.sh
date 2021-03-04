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


# HOME ASSISTANT
#
# CREATE DEFAULT .ENV FILE
if [ ! -f "./prd-home-assistant/.env" ]; 
then
printf "${color_green}No .env file found, creating a new .env with empty values${color_no}"
cat << EOF > ./prd-home-assistant/.env
HOME_ASSISTANT_MYSQL_USER=replace!
HOME_ASSISTANT_MYSQL_PASSWORD=replace!
HOME_ASSISTANT_MYSQL_ROOT_PASSWORD=replace!
HOME_ASSISTANT_MYSQL_DATABASE=home_assistant_db
TZ=Europe/Amsterdam
EOF
printf "\n\n"
fi

# ASK FOR VARIABLES TO PUT THESE INTO THE .ENV FILE
# MYSQL USER
if grep -qFx "HOME_ASSISTANT_MYSQL_USER=replace!" ./prd-home-assistant/.env
then
printf "${color_green}Enter a MYSQL USER for the Home Assistant database:${color_no}"
read home_assistant_mysql_user
sudo sed -i "s/HOME_ASSISTANT_MYSQL_USER=replace!/HOME_ASSISTANT_MYSQL_USER=$home_assistant_mysql_user/" ./prd-home-assistant/.env
fi

# MYSQL PASSWORD
if grep -qFx "HOME_ASSISTANT_MYSQL_PASSWORD=replace!" ./prd-home-assistant/.env
then
printf "${color_green}Enter a MYSQL password for the Home Assistant database:${color_no}"
read -s home_assistant_mysql_password
sudo sed -i "s/HOME_ASSISTANT_MYSQL_PASSWORD=replace!/HOME_ASSISTANT_MYSQL_PASSWORD=$home_assistant_mysql_password/" ./prd-home-assistant/.env
printf "\n"
fi

# MYSQL ROOT PASSWORD
if grep -qFx "HOME_ASSISTANT_MYSQL_ROOT_PASSWORD=replace!" ./prd-home-assistant/.env
then
printf "${color_green}Enter a MYSQL root password for the Home Assistant database:${color_no}"
read -s home_assistant_mysql_root_password
sudo sed -i "s/HOME_ASSISTANT_MYSQL_ROOT_PASSWORD=replace!/HOME_ASSISTANT_MYSQL_ROOT_PASSWORD=$home_assistant_mysql_root_password/" ./prd-home-assistant/.env
printf "\n"
fi

# BUILDING CUSTOM HOME ASSISTANT IMAGE
printf "${color_green}Building custom Home Assistant image\n${color_no}"
sleep ${sleepseconds}
# GO INTO HOME-ASSISTANT DIRECTORY
cd prd-home-assistant
# BUILD DOCKER IMAGE
sudo docker build -t prd-home-assistant-app .
# GO BACK
cd ..
printf "\n"

# ADGUARD HOME
#
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










# DOCKER COMPOSE UP
while true
do
 printf "${color_green}"
 read -r -p "Do you wish to (re)create and start the docker containers? [Y/n]" input
 printf "${color_no}"
 
 case $input in
     [yY][eE][sS]|[yY])

        printf "${color_green}Starting the docker containers\n${color_no}"
        sudo docker-compose -f ./prd-portainer/docker-compose.yml up -d \
        && sudo docker-compose -f ./prd-adguard-home/docker-compose.yml up -d \
        && sudo docker-compose -f ./prd-home-assistant/docker-compose.yml up -d
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
