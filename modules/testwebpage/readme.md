 # cloudwatch agent install & config

# ubuntu 기반 linux 에서 에이전트 설치
sudo wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb

sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# config 가져오기
 s3://kms-log-app-bucket/config.json /opt/aws/amazon-cloudwatch-agent/bin/config.json

# config 구성파일 가져오고 agent 설정
 /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

 sudo systemctl enable amazon-cloudwatch-agent
 sudo systemctl restart amazon-cloudwatch-agent