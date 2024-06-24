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

# cloudwatch agent install & config

# ubuntu 기반 linux 에서 에이전트 설치
sudo wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb

sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# config 가져오기
sudo aws s3 cp s3://kms-log-app-bucket/config.json /opt/aws/amazon-cloudwatch-agent/bin/config.json

# config 구성파일 가져오고 agent 설정
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

sudo rm ./amazon-cloudwatch-agent.deb
sudo systemctl enable amazon-cloudwatch-agent
sudo systemctl restart amazon-cloudwatch-agent
