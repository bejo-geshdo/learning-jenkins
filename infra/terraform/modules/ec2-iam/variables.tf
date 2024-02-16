variable "name" {
  description = "The prefix of the IAM role"
  type        = string
}

variable "policies" {
  description = "The list of IAM policies to attach to the role"
  type        = list(string)

  validation {
    condition     = alltrue([for policy in var.policies : can(regex("arn:aws:iam::[\"aws\"0-9]+:policy/.*", policy))])
    error_message = "Policies must be ARNs"
  }
}
