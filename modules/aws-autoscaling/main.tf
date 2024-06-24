# Creating Launch template for Web tier AutoScaling Group
/*resource "aws_launch_template" "Web-LC" {
  name = var.launch-template-name
  image_id = data.aws_ami.ami.image_id
  instance_type = "t2.micro"

  vpc_security_group_ids = [data.aws_security_group.web-sg.id]

  user_data = filebase64("./modules/aws-autoscaling/deploy.sh")
}

resource "aws_autoscaling_group" "Web-ASG" {
  name = var.asg-name
  vpc_zone_identifier  = [data.aws_subnet.public-subnet1.id, data.aws_subnet.public-subnet2.id]
  launch_template {
    id = aws_launch_template.Web-LC.id
    version = aws_launch_template.Web-LC.latest_version

  }
  min_size             = 2
  max_size             = 4
  health_check_type    = "ELB"
  health_check_grace_period = 300
  target_group_arns    = [data.aws_lb_target_group.tg.arn]
  force_delete         = true
  tag {
    key                 = "Name"
    value               = "Web-ASG"
    propagate_at_launch = true
  }
  tag {
    key = "Owner"
    value = var.Owner
    propagate_at_launch = true
  }

}


resource "aws_autoscaling_policy" "web-custom-cpu-policy" {
  name                   = "custom-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.Web-ASG.id
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}


resource "aws_cloudwatch_metric_alarm" "web-custom-cpu-alarm" {
  alarm_name          = "custom-cpu-alarm"
  alarm_description   = "alarm when cpu usage increases"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.Web-ASG.name
  }
  actions_enabled = true

  alarm_actions = [aws_autoscaling_policy.web-custom-cpu-policy.arn]
}


resource "aws_autoscaling_policy" "web-custom-cpu-policy-scaledown" {
  name                   = "custom-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.Web-ASG.id
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "web-custom-cpu-alarm-scaledown" {
  alarm_name          = "custom-cpu-alarm-scaledown"
  alarm_description   = "alarm when cpu usage decreases"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.Web-ASG.name
  }
  actions_enabled = true

  alarm_actions = [aws_autoscaling_policy.web-custom-cpu-policy-scaledown.arn]
}
*/


# Creating Launch template for App tier AutoScaling Group
resource "aws_launch_template" "App-LC" {
  name = var.launch-template-private
  image_id = data.aws_ami.ami.image_id
  instance_type = "t2.micro"
  iam_instance_profile {
    name = var.instance-profile-name
  }
  vpc_security_group_ids = [data.aws_security_group.web-sg.id]
  key_name = "kms-keypair"

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
sudo wget https://aws-codedeploy-ap-southeast-1.s3.ap-southeast-1.amazonaws.com/latest/install
sudo chmod +x ./install
sudo ./install auto
EOF
  )
}

# filebase64("./modules/aws-autoscaling/kms-deploy.sh")
resource "aws_autoscaling_group" "App-ASG" {
  name = var.asg-name2
  vpc_zone_identifier  = [data.aws_subnet.private-subnet1.id, data.aws_subnet.private-subnet2.id]
  launch_template {
    id = aws_launch_template.App-LC.id
    version = aws_launch_template.App-LC.latest_version

  }
  enabled_metrics = ["GroupMinSize","GroupMaxSize", "GroupTotalInstances", "GroupTerminatingInstances"]
  min_size             = 1
  desired_capacity = 1
  max_size             = 4
  health_check_type    = "ELB"
  health_check_grace_period = 300
  target_group_arns    = [data.aws_lb_target_group.tg2.arn]
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

resource "aws_autoscaling_policy" "app-custom-cpu-policy" {
  name                   = "custom-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.App-ASG.id
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 2
  cooldown               = 60
  policy_type            = "SimpleScaling"
}


resource "aws_cloudwatch_metric_alarm" "app-custom-cpu-alarm" {
  alarm_name          = "custom-cpu-alarm"
  alarm_description   = "alarm when cpu usage increases"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = "70"

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.App-ASG.name
  }
  actions_enabled = true

  alarm_actions = [aws_autoscaling_policy.app-custom-cpu-policy.arn]
}


resource "aws_autoscaling_policy" "app-custom-cpu-policy-scaledown" {
  name                   = "custom-cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.App-ASG.id
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "app-custom-cpu-alarm-scaledown" {
  alarm_name          = "custom-cpu-alarm-scaledown"
  alarm_description   = "alarm when cpu usage decreases"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    "AutoScalingGroupName" : aws_autoscaling_group.App-ASG.name
  }
  actions_enabled = true

  alarm_actions = [aws_autoscaling_policy.app-custom-cpu-policy-scaledown.arn]
}

# CodeDeploy 애플리케이션 생성
resource "aws_codedeploy_app" "my_app" {
  name = "kms-CodeDeploy-App"
}

data "aws_iam_role" "forCodeDeploy" {
  name = "CodeDeployServiceRole"
}


# CodeDeploy 배포 그룹 생성
resource "aws_codedeploy_deployment_group" "my_deployment_group" {
  app_name              = aws_codedeploy_app.my_app.name
  deployment_group_name = "kms-DeploymentGroup"
  service_role_arn      = data.aws_iam_role.forCodeDeploy.arn

  deployment_config_name = "CodeDeployDefault.OneAtATime"

  # EC2 인스턴스 또는 Auto Scaling 그룹을 지정
  autoscaling_groups = ["${aws_autoscaling_group.App-ASG.name}"]

  # 배포 옵션
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }

    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }
  }

  load_balancer_info {
    target_group_info {
      name = "App-TG-kms"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  tags = {
    createDate = formatdate("YYYY-MM-DD", timestamp())
    Name        = "DeploymentGroup"
    Owner       = "kms"
  }

  depends_on = [ aws_autoscaling_group.App-ASG ]
}