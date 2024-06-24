#!/bin/bash

# AWS CLI 설치
sudo apt update -y
sudo apt-get install -y curl
sudo apt install -y awscli
sudo apt install -y apache2 php libapache2-mod-php nfs-common
sudo apt install composer -y

sudo mkdir -p /mnt/efs


# php 파일 복사
aws s3 cp s3://www.mintstone.store-active/dynamic/ ~/dynamic/ --recursive
sudo cp ~/dynamic/*.php /var/www/html/
sudo rm -rf ~/dynamic

# Apache 웹 서버 시작
sudo systemctl start apache2 && sudo systemctl enable apache2
sudo chown -R www-data:www-data /var/www/html && sudo chmod -R 755 /var/www/html


# 웹 서버 재시작
sudo systemctl restart apache2

