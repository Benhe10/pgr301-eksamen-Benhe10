variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "namespace" {
  description = "CloudWatch metrics namespace used by the app"
  type        = string
  default     = "SentimentApp"
}

variable "alarm_email" {
  description = "Email to subscribe to SNS alarm notifications (optional)"
  type        = string
  default     = ""
}
