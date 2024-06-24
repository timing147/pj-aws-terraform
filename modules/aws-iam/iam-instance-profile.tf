resource "aws_iam_instance_profile" "test_profile" {
  name = var.instance-profile-name
  role = aws_iam_role.iam-role.name
}
output "main-instance-profile" {
  value = aws_iam_instance_profile.test_profile.name
}