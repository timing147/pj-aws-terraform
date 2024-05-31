# EFS 파일 시스템 생성
resource "aws_efs_file_system" "efs" {

  # 유휴 시 데이터 암호화
  encrypted = true
  # KMS에서 관리형 키를 이용하려면 kms_key_id 속성을 붙여줍니다.

  # 성능 모드: generalPurpose(범용 모드), maxIO(최대 IO 모드)
  performance_mode = "generalPurpose"
  
  # 버스팅 처리량 모드
  throughput_mode = "bursting"

  # 수명 주기 관리
  lifecycle_policy {
    transition_to_ia = "AFTER_90_DAYS"
  }
  tags = {
    Name = "kms-efs"
    Owner = "kms"
    CreateData = formatdate("YYYY-MM-DD", timestamp())
  }
}

resource "aws_efs_mount_target" "mount1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = data.aws_subnet.private-subnet1.id
  security_groups = [data.aws_security_group.efs-sg.id]
}

resource "aws_efs_mount_target" "mount2" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = data.aws_subnet.private-subnet2.id
  security_groups = [data.aws_security_group.efs-sg.id]
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.efs.id
  backup_policy {
    status = "ENABLED"
  }
}


data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "ExampleStatement01"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite",
    ]

    resources = [aws_efs_file_system.efs.arn]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.efs.id
  policy         = data.aws_iam_policy_document.policy.json
}