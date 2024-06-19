resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucketname
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    object_ownership = "BucketOwnerPreffered"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [ aws_s3_bucket_ownership_controls.example, aws_s3_bucket_public_access_block.example ]

  bucket = aws_s3_bucket.mybucket.id
  acl = "public-read"
}

resource "null_resource" "example" {
  depends_on = [ aws_s3_bucket_acl.example ]

  provisioner "local-exec" {
    command = "aws s3 sync ./build s3://${aws_s3_bucket.mybucket.bucket} --acl public-read"
  }
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.mybucket.id
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
  depends_on = [ aws_s3_bucket_acl.example ]
}