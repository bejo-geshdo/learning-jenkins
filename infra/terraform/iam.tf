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

#Policy and roles for Jenkins controller
data "aws_iam_policy_document" "iam_policy" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeSpotFleetInstances",
      "ec2:ModifySpotFleetRequest",
      "ec2:CreateTags",
      "ec2:DescribeRegions",
      "ec2:DescribeInstances",
      "ec2:TerminateInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeSpotFleetRequests",
      "ec2:DescribeFleets",
      "ec2:DescribeFleetInstances",
      "ec2:ModifyFleet",
      "ec2:DescribeInstanceTypes"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:UpdateAutoScalingGroup"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:ListInstanceProfiles",
      "iam:ListRoles"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"

      values = [
        "ec2.amazonaws.com",
        "ec2.amazonaws.com.cn"
      ]
    }
  }
}


resource "aws_iam_role" "jenkins-controller" {
  name_prefix        = "jenkins-controller-"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust_policy.json
}

resource "aws_iam_instance_profile" "jenkins-controller" {
  name_prefix = "jenkins-controller-"
  path        = "/ecs/instnace/"
  role        = aws_iam_role.jenkins-controller.name
}

resource "aws_iam_policy" "jenkins-controller" {
  name_prefix = "jenkins-controller-"
  description = "Allows spinning up EC2 instances and mange ASG"
  policy      = data.aws_iam_policy_document.iam_policy.json
}

resource "aws_iam_role_policy_attachment" "jenkins-controller" {
  role       = aws_iam_role.jenkins-controller.name
  policy_arn = aws_iam_policy.jenkins-controller.arn
}

# EC2 instances for Jenkins agent

data "aws_iam_policy_document" "frontend_s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.frontend_bucket.arn, "${aws_s3_bucket.frontend_bucket.arn}/*"]
  }
}

resource "aws_iam_policy" "frontend_s3_access" {
  name        = "frontend_s3_access"
  description = "Allows Jenkins agents to access frontend S3"
  policy      = data.aws_iam_policy_document.frontend_s3_access.json
}

resource "aws_iam_role" "jenkins-agent" {
  name_prefix        = "jenkins-agent-"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust_policy.json
}

resource "aws_iam_instance_profile" "jenkins-agent" {
  name_prefix = "jenkins-agent-"
  path        = "/ecs/instnace/"
  role        = aws_iam_role.jenkins-agent.name
}

resource "aws_iam_policy_attachment" "jenkins-agent" {
  name       = "jenkins-agent"
  roles      = [aws_iam_role.jenkins-agent.name]
  policy_arn = aws_iam_policy.frontend_s3_access.arn
}
