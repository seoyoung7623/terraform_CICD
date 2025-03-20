#ec2 Role
resource "aws_iam_role" "ec2-iam-role" {
  name ="aws-iam-${var.stage}-${var.servicename}-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = var.tags

}

resource "aws_iam_instance_profile" "ec2-iam-role-profile" {
  name = "aws-iam-${var.stage}-${var.servicename}-ec2-role-profile"
  role = aws_iam_role.ec2-iam-role.name
}

resource "aws_iam_role" "terraform_role" {
  name = "TerraformRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::471112976134:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_s3_policy" {
  name        = "TerraformS3Policy"
  description = "Allow Terraform to manage S3 state"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketPolicy",
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::seoyoung-terraformstate-s3",
          "arn:aws:s3:::seoyoung-terraformstate-s3/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_terraform_s3_policy" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = aws_iam_policy.terraform_s3_policy.arn
}
