resource "aws_launch_template" "App-LC" {
  name = var.launch-template-private
  image_id = data.aws_ami.ami.image_id
  instance_type = "t2.micro"
  iam_instance_profile {
    name = var.main-instance-profile-name
  }
  vpc_security_group_ids = [aws_security_group.web-tier-sg.id]
  key_name = "kms-keypair-oregon"

  user_data = base64encode(<<-EOF
#!bin/bash

# EFS 마운트하기
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-05743c039f48b8ae5.efs.ap-southeast-1.amazonaws.com:/ /mnt/efs
# sample file create
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
sudo touch /home/ubuntu/$INSTANCE_ID.txt
echo $INSTANCE_ID > /home/ubuntu/$INSTANCE_ID.txt
sudo cp /home/ubuntu/$INSTANCE_ID.txt /mnt/efs/$INSTANCE_ID.txt
# 사전 설치
sudo apt install ruby-full -y
sudo apt install wget -y
#codedeploy-agent install
sudo wget https://aws-codedeploy-us-west-2.s3.us-west-2.amazonaws.com/latest/install
sudo chmod +x ./install
sudo ./install auto
EOF
  )
}

resource "aws_autoscaling_group" "App-ASG" {
  name = var.asg-name
  vpc_zone_identifier  = [aws_subnet.private-subnet1.id, aws_subnet.private-subnet1.id]
  launch_template {
    id = aws_launch_template.App-LC.id
    version = aws_launch_template.App-LC.latest_version

  }
  enabled_metrics = ["GroupMinSize","GroupMaxSize", "GroupTotalInstances", "GroupTerminatingInstances"]
  min_size             = 0
  max_size             = 2
  health_check_type    = "ELB"
  health_check_grace_period = 300
  target_group_arns    = [aws_lb_target_group.app-tg.arn]
  force_delete         = true
  tag {
    key                 = "Name"
    value               = "App-ASG"
    propagate_at_launch = true
  }
  tag {
    key = "Owner"
    value = var.Owner
    propagate_at_launch = true
  }
  tag {
    key = "CreateDate"
    value = formatdate("YYYY-MM-DD", timestamp())
    propagate_at_launch = true
  }
}