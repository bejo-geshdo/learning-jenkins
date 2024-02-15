output "aws_iam_instance_profile_name" {
  value = aws_iam_instance_profile.ec2-role.name
}

output "aws_iam_role" {
  value = aws_iam_role.ec2-role
}
