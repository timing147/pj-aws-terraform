# VPC
VPC-NAME         = "3-Tier-VPC"
VPC-CIDR         = "10.0.0.0/16"
IGW-NAME         = "3-Tier-Interet-Gateway"
PUBLIC-CIDR1     = "10.0.1.0/24"
PUBLIC-SUBNET1   = "3-Tier-Public-Subnet1"
PUBLIC-CIDR2     = "10.0.2.0/24"
PUBLIC-SUBNET2   = "3-Tier-Public-Subnet2"
PRIVATE-CIDR1    = "10.0.3.0/24"
PRIVATE-SUBNET1  = "3-Tier-Private-Subnet1"
PRIVATE-CIDR2    = "10.0.4.0/24"
PRIVATE-SUBNET2  = "3-Tier-Private-Subnet2"
PRIVATE-CIDR3    = "10.0.5.0/24"
PRIVATE-SUBNET3  = "3-Tier-Private-Subnet3"
PRIVATE-CIDR4    = "10.0.6.0/24"
PRIVATE-SUBNET4  = "3-Tier-Private-Subnet4"
EIP-NAME1        = "3-Tier-Elastic-IP1"
EIP-NAME2        = "3-Tier-Elastic-IP2"
NGW-NAME1        = "3-Tier-NAT1"
NGW-NAME2        = "3-Tier-NAT2"
PUBLIC-RT-NAME1  = "3-Tier-Public-Route-table1"
PUBLIC-RT-NAME2  = "3-Tier-Public-Route-table2"
PRIVATE-RT-NAME1 = "3-Tier-Private-Route-table1"
PRIVATE-RT-NAME2 = "3-Tier-Private-Route-table2"
AZ-1             = "ap-southeast-1a"
AZ-2             = "ap-southeast-1b"

# SECURITY GROUP
ALB-SG-NAME = "3-Tier-alb-sg"
WEB-SG-NAME = "3-Tier-web-sg"
DB-SG-NAME  = "3-Tier-db-sg"


# RDS
SG-NAME      = "kms-rds-sg"
RDS-USERNAME = "admin"
RDS-PWD      = "Admin1234"
DB-NAME      = "mydb"
RDS-NAME     = "3-Tier-RDS"

# ALB
TG-NAME   = "Web-TG"
TG-NAME2  = "App-TG"
ALB-NAME  = "Web-elb"
ALB-NAME2 = "App-elb"

# IAM
IAM-ROLE              = "iam-role-for-ec2-SSM-kms"
IAM-POLICY            = "iam-policy-for-ec2-SSM-kms"
INSTANCE-PROFILE-NAME = "iam-instance-profile-for-ec2-SSM-kms"

# AUTOSCALING
AMI-NAME             = "New-AMI"
LAUNCH-TEMPLATE-NAME = "Web-template"
ASG-NAME             = "3-Tier-ASG-web"
ASG-NAME2            = "3-Tier-ASG-app"

LAUNCH-TEMPLATE-PRIVATE = "App-template"

# CLOUDFRONT
DOMAIN-NAME = "mintstone.store"
CDN-NAME    = "3-Tier-CDN"

# WAF
WEB-ACL-NAME = "3-Tier-WAF"

#s3
STATIC-FILE   = "index.html"
STATIC-SOURCE = "./modules/aws-static-s3/index.html"
BUCKET-NAME   = "mintstone-static-kms1379"

#private
OWNER      = "kms"
CREATEDATE = "2024.05.03"