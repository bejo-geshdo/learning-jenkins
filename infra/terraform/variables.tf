variable "aws_account_id" {
  type        = string
  description = "The ID of your AWS account"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "The aws_account_id must be a 12 digit number."
  }
}

variable "home_IP" {
  type        = string
  description = "Your home IP address"

  validation {
    condition     = can(regex("^((25[0-5]|(2[0-4]|1\\d|[1-9]|)\\d)\\.?\\b){4}$", var.home_IP))
    error_message = "The home_IP must be a valid IPv4 address."
  }
}

variable "office_IP" {
  type        = string
  description = "Your offices IP address"

  validation {
    condition     = can(regex("^((25[0-5]|(2[0-4]|1\\d|[1-9]|)\\d)\\.?\\b){4}$", var.office_IP))
    error_message = "The office_ip must be a valid IPv4 address."
  }
}