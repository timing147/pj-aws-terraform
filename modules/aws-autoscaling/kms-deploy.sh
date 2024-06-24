#!/bin/bash

INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
echo ${INSTANCE_ID} > /home/ubuntu/${INSTANCE_ID}.txt
sudo cp /home/ubuntu/${INSTANCE_ID}.txt /mnt/efs/${INSTANCE_ID}.txt

sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${data.aws_efs_file_system.efs.dns_name}:/ /mnt/efs

# AWS SDK for PHP 설치
#sudo mkdir -p ~/sdk
#sudo cd ~/sdk
#sudo composer require aws/aws-sdk-php
#sudo cp -r ~/sdk/vendor /var/www/html/
#sudo cp ~/sdk/composer.* /var/www/html/