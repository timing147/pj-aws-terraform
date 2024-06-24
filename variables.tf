# VPC
variable "VPC-NAME" {}
variable "VPC-CIDR" {}
variable "IGW-NAME" {}
variable "PUBLIC-CIDR1" {}
variable "PUBLIC-SUBNET1" {}
variable "PUBLIC-CIDR2" {}
variable "PUBLIC-SUBNET2" {}
variable "PRIVATE-CIDR1" {}
variable "PRIVATE-SUBNET1" {}
variable "PRIVATE-CIDR2" {}
variable "PRIVATE-SUBNET2" {}
variable "EIP-NAME1" {}
variable "EIP-NAME2" {}
variable "NGW-NAME1" {}
variable "NGW-NAME2" {}
variable "PUBLIC-RT-NAME1" {}
variable "PUBLIC-RT-NAME2" {}
variable "PRIVATE-RT-NAME1" {}
variable "PRIVATE-RT-NAME2" {}
variable "AZ-1" {}
variable "AZ-2" {}
variable "PRIVATE-SUBNET3" {}
variable "PRIVATE-SUBNET4" {}
variable "PRIVATE-CIDR3" {}
variable "PRIVATE-CIDR4" {}

# SECURITY GROUP
variable "ALB-SG-NAME" {}
variable "WEB-SG-NAME" {}
variable "DB-SG-NAME" {}
variable "EFS-SG-NAME" {}

# RDS
variable "SG-NAME" {}
variable "RDS-USERNAME" {}
variable "RDS-PWD" {}
variable "DB-NAME" {}
variable "RDS-NAME" {}


# ALB
variable "TG-NAME" {}
variable "TG-NAME2" {}
variable "ALB-NAME" {}
variable "ALB-NAME2" {}

# IAM
variable "IAM-ROLE" {}
variable "IAM-POLICY" {}
variable "INSTANCE-PROFILE-NAME" {}

# AUTOSCALING
variable "AMI-NAME" {}
variable "LAUNCH-TEMPLATE-NAME" {}
variable "ASG-NAME" {}
variable "LAUNCH-TEMPLATE-PRIVATE" {}

variable "ASG-NAME2" {}

# CLOUDFFRONT
variable "DOMAIN-NAME" {}
variable "CDN-NAME" {}

# WAF
variable "WEB-ACL-NAME" {}

#s3
variable "STATIC-FILE" {}
variable "STATIC-SOURCE" {}
variable "BUCKET-NAME" {}
variable "OWNER" {}
variable "CREATEDATE" {}

#dynamodb
variable "REGION_SINGAPORE" {}
variable "VPC-SUB-NAME" {}

#
variable "KMS-ALIAS" {}

# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}
# variable "" {}