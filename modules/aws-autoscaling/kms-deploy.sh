#!/bin/bash

# AWS CLI 설치
sudo apt update -y
sudo apt install -y awscli
sudo apt install -y apache2 php libapache2-mod-php
sudo apt install composer -y
export DYNAMODB_REGION=ap-southeast-1

sudo mkdir -p efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${data.aws_efs_file_system.efs.dns_name}:/ efs

# AWS SDK for PHP 설치
cd /var/www/html
composer require aws/aws-sdk-php -y

# sdk 파일 코드 파일에 복사하기
# php 파일 복사
aws s3 cp s3://www.mintstone.store-active/api/ ~/api/ --recursive
sudo cp ~/api/*.php /var/www/html/
sudo rm -rf ~/api

# Apache 웹 서버 시작
sudo systemctl start apache2 && sudo systemctl enable apache2
sudo chown -R www-data:www-data /var/www/html && sudo chmod -R 755 /var/www/html

# 웹 서버 재시작
sudo systemctl restart apache2
