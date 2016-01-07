#!/bin/bash
# Requires CentOS 7 and installed GitHub SSH key

# Update base packages and install some essentials
yum install -y epel-release
yum update -y
yum install -y ntp vim tmux screen git

# Create ktang user
adduser ktang
gpasswd -a ktang wheel
cp -pr /root/.ssh /home/ktang/

# Update ssh config
echo "PermitRootLogin no\n" >> /etc/ssh/sshd_config
systemctl reload sshd

# Login as ktang
su - ktang

# Install Docker and Docker Compose
curl -sSL https://get.docker.com/ | sh
sudo service docker start
sudo usermod -aG docker ktang
sudo chkconfig docker on
sudo -i curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Firewall settings
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

# Time settings
sudo timedatectl set-timezone America/New_York
sudo systemctl enable ntpd
sudo systemctl start ntpd

# Swap settings
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo sh -c 'echo "/swapfile none swap sw 0 0" >> /etc/fstab'

# Checkout app repos
cd
mkdir -p src/SDBP src/WRB src/docker-vraxx
cd src/SDBP && git clone git@github.com:KevinTangy/SimpleDBPokedex.git .
cd src/WRB && git clone git@github.com:KevinTangy/WITworks-Review-Board.git .
cd src/docker-vraxx && git clone git@github.com:KevinTangy/docker-vraxx.git .
cd

# Start Docker containers
cd src/docker-vraxx && docker-compose up -d
cd

# Quick verification
# todo

echo "Done! Containers are go!"
