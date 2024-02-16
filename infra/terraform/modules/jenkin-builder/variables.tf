variable "name" {
  description = "Prefix for the Jenkins agent launch template name"
  type        = string
  default     = "tf-jenkins-agent-"
}

variable "ami_name_filter" {
  description = "Filter for the AMI name"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the Jenkins agent"
  type        = string
  default     = "t2.small"
}

variable "key_name" {
  description = "SSH key name for the Jenkins agent"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile for the Jenkins agent"
  type        = string
  nullable    = true
}

variable "security_groups" {
  description = "Set of security group IDs for the Jenkins agent"
  type        = set(string)
}

variable "volume_size" {
  description = "Volume size for the Jenkins agent"
  type        = number
  default     = 0
}

variable "subnet_ids" {
  description = "Set of subnet IDs for the Jenkins agent autoscaling group"
  type        = set(string)
}

variable "user_data_b64" {
  description = "User data for the Jenkins agent, base64 encoded"
  type        = string
  default     = ""

  validation {
    condition     = var.user_data_b64 == "" || can(base64decode(var.user_data_b64))
    error_message = "The user_data_b64 variable must be a valid base64 string."
  }
}
