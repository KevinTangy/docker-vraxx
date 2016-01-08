#!/bin/bash
# Requires CentOS 7 and installed GitHub SSH key
# Arg 1 is WRB db user and Arg 2 is WRB db password

WRB_DB_USER=$1
WRB_DB_PASS=$2

GREEN='\e[0;32m'
NC='\e[0m'

# Update .bashrc


# Update base packages and install some essentials
printf "${GREEN}\nInstalling/updating base packages...\n\n${NC}"
yum install -y epel-release
yum update -y
yum install -y ntp vim tmux screen git
printf "${GREEN}\n...Done\n\n${NC}"

# Create ktang user
MY_USER=ktang
printf "${GREEN}\nAdding ${MY_USER} user...\n\n${NC}"
adduser $MY_USER
gpasswd -a $MY_USER wheel
cp -pr /root/.ssh /home/${MY_USER}/
# cp /root/.bashrc /home/${MY_USER}/
chown -R ${MY_USER}:${MY_USER} /home/${MY_USER}/
printf "${GREEN}\n...Done\n\n${NC}"

# Update ssh config
printf "${GREEN}\nUpdating ssh config...\n\n${NC}"
echo -e "\nPermitRootLogin no\nPasswordAuthentication no\nChallengeResponseAuthentication no\nKerberosAuthentication no\n" >> /etc/ssh/sshd_config
systemctl restart sshd
printf "${GREEN}\n...Done\n\n${NC}"

# Install Docker and Docker Compose
printf "${GREEN}\nInstalling Docker and Docker Compose...\n\n${NC}"
curl -sSL https://get.docker.com/ | sh
sudo service docker start
sudo usermod -aG docker ktang
sudo chkconfig docker on
sudo -i curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
printf "${GREEN}\n...Done\n\n${NC}"

# Firewall settings
printf "${GREEN}\nSetting firewall settings...\n\n${NC}"
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
printf "${GREEN}\n...Done\n\n${NC}"

# Time settings
printf "${GREEN}\nSetting time settings...\n\n${NC}"
sudo timedatectl set-timezone America/New_York
sudo systemctl enable ntpd
sudo systemctl start ntpd
printf "${GREEN}\n...Done\n\n${NC}"

# Swap settings
printf "${GREEN}\nSetting swap settings...\n\n${NC}"
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo sh -c 'echo "/swapfile none swap sw 0 0" >> /etc/fstab'
printf "${GREEN}\n...Done\n\n${NC}"

# Checkout app repos
printf "${GREEN}\nGrabbing git repos...\n\n${NC}"
cd
mkdir src
cd src
git clone https://github.com/KevinTangy/SimpleDBPokedex.git SDBP
git clone https://github.com/KevinTangy/WITworks-Review-Board.git WRB
#sed /$username = '';/$WRB_DB_USER/ /$password = '';/$WRB_DB_PASS/  WRB/config.php  docker-compose.yml
git clone https://github.com/KevinTangy/docker-vraxx.git
cd
printf "${GREEN}\n...Done\n\n${NC}"

# Restart Docker service so it plays nice with firewalld
sudo service docker restart

# Start Docker containers
printf "${GREEN}\nRunning Docker Compose to bring up containers...\n\n${NC}"
cd src/docker-vraxx && docker-compose up -d
cd
printf "${GREEN}\n...Done\n\n${NC}"

# Quick verification
# todo

printf "${GREEN}\nAll done! Containers are go!\n${NC}"
