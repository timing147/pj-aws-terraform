resource "aws_s3_bucket" "stone-static-bucket" {
  bucket = var.bucket-name

  tags = merge(var.common-tags, {Name = "mintstone.store"})

  
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
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::${var.bucket-name}/*"
      ]
    },
    {
      "Sid": "PublicBucketAccess",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetBucketAcl",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::${var.bucket-name}"
      ]
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

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.stone-static-bucket.id

  index_document {
    suffix = "index.html"
  }



  #error_document {
  #  key = "error.html"
  #}

  #routing_rule {
  #  condition {
  #    key_prefix_equals = "docs/"
  #  }
  #  redirect {
  #    replace_key_prefix_with = "documents/"
  #  }
  #}
}
#kms key generate
#resource "aws_kms_key" "mykey" {
#  description             = "This key is used to encrypt bucket objects"
#  deletion_window_in_days = 10
#}

#server-side encryption default
resource "aws_s3_bucket_server_side_encryption_configuration" "s3-key" {
  depends_on = [ aws_s3_object.s3-static-html ]

  bucket = aws_s3_bucket.stone-static-bucket.id

  rule {
    bucket_key_enabled = true
  }
}