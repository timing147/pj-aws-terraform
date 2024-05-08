resource "aws_s3_bucket" "stone-static-bucket" {
  bucket = var.bucket-name

  tags = {
    Name = "Static-Bucket"
    Owner = var.Owner
    CreateDate = var.CreateDate
  }
}

resource "aws_s3_bucket_acl" "static-acl" {
  bucket = aws_s3_bucket.stone-static-bucket.id
  acl = "public-read"
}


resource "aws_s3_bucket_public_access_block" "public-access" {
  depends_on = [ aws_s3_bucket.stone-static-bucket ]

  bucket = aws_s3_bucket.stone-static-bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  
}

resource "aws_s3_bucket_policy" "static-policy" {
  depends_on = [ aws_s3_bucket_public_access_block.public-access ]

  bucket = aws_s3_bucket.stone-static-bucket.id  
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"PublicRead",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${aws_s3_bucket.stone-static-bucket.id}/*"]
    }
  ]
}
POLICY
}

resource "aws_s3_object" "s3-static-html" {
  depends_on = [ aws_s3_bucket_policy.static-policy ]

  bucket = aws_s3_bucket.stone-static-bucket.id
  key = var.static-file
  source = var.static-source

  
  
}