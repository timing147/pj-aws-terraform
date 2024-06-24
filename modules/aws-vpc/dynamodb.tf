resource "aws_vpc_endpoint" "dynamodb_endpoint" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.region_singapore}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.public-rt1.id,
    aws_route_table.public-rt2.id,
    aws_route_table.private-rt1.id,
    aws_route_table.private-rt2.id
  ]
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": [
        "arn:aws:dynamodb:${var.region_singapore}:${data.aws_caller_identity.current.account_id}:table/main_table_kms"
      ]
    }
  ]
}
POLICY
  tags = {
    Name       = "dynamodb-vpc-endpoint-singapore"
    createDate = formatdate("YYYY-MM-DD", timestamp())
    Owner      = "kms"
  }
}

# 1차 구성, ddb 테이블
resource "aws_dynamodb_table" "main_table_singapore" {
  provider     = aws.ap-southeast-1
  name         = "main_table_kms"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  tags = {
    createDate = formatdate("YYYY-MM-DD", timestamp())
    Owner      = "kms"
    Name       = "main_table"
  }
}

resource "aws_dynamodb_table_item" "check" {
  depends_on = [aws_dynamodb_global_table.main_table, ]
  table_name = aws_dynamodb_table.main_table_singapore.name
  hash_key   = aws_dynamodb_table.main_table_singapore.hash_key
  item       = <<ITEM
{
  "user_id": {"S": "testuser"},
  "user_name": {"S": "minseok"},
  "user_password": {"S": "test1234"}
}
ITEM
}

resource "aws_dynamodb_table" "main_table_oregon" {
  provider     = aws.us-west-2
  name         = "main_table_kms"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  tags = {
    createDate = formatdate("YYYY-MM-DD", timestamp())
    Owner      = "kms"
    Name       = "main_table_kms"
  }
}

resource "aws_dynamodb_global_table" "main_table" {
  depends_on = [
    aws_dynamodb_table.main_table_singapore,
    aws_dynamodb_table.main_table_oregon
  ]

  provider = aws.ap-southeast-1

  name = "main_table_kms"

  replica {
    region_name = "ap-southeast-1"
  }

  replica {
    region_name = "us-west-2"
  }
}
