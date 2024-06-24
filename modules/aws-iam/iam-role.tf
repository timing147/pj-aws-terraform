
#variable "iam_role_name" {
#  description = "The name of the IAM role"
#  type        = string
#}

resource "aws_iam_role" "iam-role" {
  name               = var.iam-role
  assume_role_policy = file("${path.module}/iam-role.json")
} 


resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_server_policy" {
  role       = aws_iam_role.iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
