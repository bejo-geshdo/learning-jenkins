#Allows EC2 to use the role
data "aws_iam_policy_document" "ec2_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2-role" {
  name_prefix        = var.name
  assume_role_policy = data.aws_iam_policy_document.ec2_trust_policy.json
}


resource "aws_iam_role_policy_attachment" "ec2-role" {
  count      = length(var.policies)
  role       = aws_iam_role.ec2-role.name
  policy_arn = var.policies[count.index]
}

resource "aws_iam_instance_profile" "ec2-role" {
  name_prefix = var.name //var.name
  path        = "/ecs/instnace/"
  role        = aws_iam_role.ec2-role.arn
}
