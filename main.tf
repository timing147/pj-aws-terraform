
module "vpc" {
  source = "./modules/aws-vpc"

  vpc-name        = var.VPC-NAME
  vpc-cidr        = var.VPC-CIDR
  igw-name        = var.IGW-NAME
  public-cidr1    = var.PUBLIC-CIDR1
  public-subnet1  = var.PUBLIC-SUBNET1
  public-cidr2    = var.PUBLIC-CIDR2
  public-subnet2  = var.PUBLIC-SUBNET2
  private-cidr1   = var.PRIVATE-CIDR1
  private-subnet1 = var.PRIVATE-SUBNET1
  private-cidr2   = var.PRIVATE-CIDR2
  private-subnet2 = var.PRIVATE-SUBNET2
  eip-name1       = var.EIP-NAME1
  eip-name2       = var.EIP-NAME2

  private-cidr3   = var.PRIVATE-CIDR3
  private-cidr4   = var.PRIVATE-CIDR4
  private-subnet3 = var.PRIVATE-SUBNET3
  private-subnet4 = var.PRIVATE-SUBNET4

  ngw-name1        = var.NGW-NAME1
  ngw-name2        = var.NGW-NAME2
  public-rt-name1  = var.PUBLIC-RT-NAME1
  public-rt-name2  = var.PUBLIC-RT-NAME2
  private-rt-name1 = var.PRIVATE-RT-NAME1
  private-rt-name2 = var.PRIVATE-RT-NAME2
  az-1             = var.AZ-1
  az-2             = var.AZ-2
  Owner            = var.OWNER
  CreateDate       = var.CREATEDATE
} 

module "security-group" {
  source = "./modules/security-group"

  vpc-name    = var.VPC-NAME
  alb-sg-name = var.ALB-SG-NAME
  web-sg-name = var.WEB-SG-NAME
  db-sg-name  = var.DB-SG-NAME
  Owner       = var.OWNER
  CreateDate  = var.CREATEDATE

  depends_on = [module.vpc]
}

module "rds" {
  source = "./modules/aws-rds"

  sg-name              = var.SG-NAME
  private-subnet-name3 = var.PRIVATE-SUBNET3
  private-subnet-name4 = var.PRIVATE-SUBNET4
  db-sg-name           = var.DB-SG-NAME
  rds-username         = var.RDS-USERNAME
  rds-pwd              = var.RDS-PWD
  db-name              = var.DB-NAME
  rds-name             = var.RDS-NAME
  Owner = var.OWNER
  CreateDate = var.CREATEDATE

  depends_on = [module.security-group]
}


module "alb" {
  source = "./modules/alb-tg"

  public-subnet-name1  = var.PUBLIC-SUBNET1
  public-subnet-name2  = var.PUBLIC-SUBNET2
  web-alb-sg-name      = var.ALB-SG-NAME
  alb-name             = var.ALB-NAME
  tg-name              = var.TG-NAME
  tg-name2             = var.TG-NAME2
  vpc-name             = var.VPC-NAME
  alb-name2            = var.ALB-NAME2
  private-subnet-name1 = var.PRIVATE-SUBNET1
  private-subnet-name2 = var.PRIVATE-SUBNET2
  Owner                = var.OWNER
  CreateDate           = var.CREATEDATE

  depends_on = [/*module.rds*/ module.security-group]
}



module "iam" {
  source = "./modules/aws-iam"

  iam-role              = var.IAM-ROLE
  iam-policy            = var.IAM-POLICY
  instance-profile-name = var.INSTANCE-PROFILE-NAME

  depends_on = [module.alb]
}


module "autoscaling" {
  source = "./modules/aws-autoscaling"

  ami_name                = var.AMI-NAME
  launch-template-name    = var.LAUNCH-TEMPLATE-NAME
  instance-profile-name   = var.INSTANCE-PROFILE-NAME
  web-sg-name             = var.WEB-SG-NAME
  tg-name                 = var.TG-NAME
  iam-role                = var.IAM-ROLE
  public-subnet-name1     = var.PUBLIC-SUBNET1
  public-subnet-name2     = var.PUBLIC-SUBNET2
  asg-name                = var.ASG-NAME
  launch-template-private = var.LAUNCH-TEMPLATE-PRIVATE
  private-subnet-name1    = var.PRIVATE-SUBNET1
  private-subnet-name2    = var.PRIVATE-SUBNET2
  tg-name2                = var.TG-NAME2

  asg-name2  = var.ASG-NAME2
  Owner      = var.OWNER
  CreateDate = var.CREATEDATE

  depends_on = [module.iam]
}
module "s3" {
  source        = "./modules/aws-static-s3"
  bucket-name   = var.BUCKET-NAME
  static-file   = var.STATIC-FILE
  static-source = var.STATIC-SOURCE
  Owner         = var.OWNER
  CreateDate    = var.CREATEDATE

}


module "route53" {
  source = "./modules/aws-waf-cdn-acm-route53"

  domain-name  = var.DOMAIN-NAME
  cdn-name     = var.CDN-NAME
  web_acl_name = var.WEB-ACL-NAME
  alb-dns-name = module.alb.alb_dns_name
  alb-name     = var.ALB-NAME
  Owner        = var.OWNER
  CreateDate   = var.CREATEDATE
  s3-dns-name  = module.s3.s3_bucket_domain
  s3-id        = module.s3.s3_bucket_id
  providers = {
    aws = aws.us-east-1
  }

  depends_on = [module.autoscaling]

}
