#Policies for Jenkins controller
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
resource "aws_iam_policy" "jenkins-controller" {
  name_prefix = "jenkins-controller-"
  description = "Allows spinning up EC2 instances and mange ASG"
  policy      = data.aws_iam_policy_document.iam_policy.json
}

#Policies for Jenkins frontend agent
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

#Policies for Jenkins packer agent

data "aws_iam_policy_document" "packer_ami_builder" {
  statement {
    actions = [
      "ec2:Describe*",
      "ec2:CreateSnapshot",
      "ec2:CreateImage",
      "ec2:DeleteSnapshot",
      "ec2:DeleteImage",
      "ec2:RegisterImage",
      "ec2:CreateVolume",
      "ec2:DeleteVolume",
      "ec2:ModifyImageAttribute",
      "ec2:ModifySnapshotAttribute",
      "ec2:CopySnapshot",
      "ec2:CopyImage",
      "ec2:CreateTags",
      "ec2:ModifyInstanceAttribute",
      "ec2:StopInstances",
      "ec2:TerminateInstances",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:RunInstances",
      "ec2:StartInstances"
    ]

    resources = ["*"]
  }

  //TODO Limit to only launch t2.micro instances
  //TODO maybe limit to only create and terminate instances with a specific tag
}

resource "aws_iam_policy" "packer_ami_builder" {
  name        = "packer_ami_builder"
  description = "Policy for service that builds and stores AMIs"
  policy      = data.aws_iam_policy_document.packer_ami_builder.json
}


#Roles and instance profiles
module "jenkin-contoller-iam" {
  source = "./modules/ec2-iam"

  name = "jenkins-controller-"
  policies = [
    aws_iam_policy.jenkins-controller.arn,
  ]
}

module "jenkin-agent-iam" {
  source = "./modules/ec2-iam"

  name = "jenkins-agent-"
  policies = [
    aws_iam_policy.frontend_s3_access.arn,
  ]
}

module "jenkins-agent-packer-iam" {
  source = "./modules/ec2-iam"

  name = "jenkins-agent-packer-"
  policies = [
    aws_iam_policy.packer_ami_builder.arn
  ]
}
