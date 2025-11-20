terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region                      = var.region
  skip_credentials_validation = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
  # Når du kjører mot ekte AWS, fjern disse linjene eller sett gyldige credentials.
}

# SNS topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "aialpha-alerts"
}

# Optional email subscription (only created if alarm_email is non-empty)
resource "aws_sns_topic_subscription" "email_sub" {
  count = length(trimspace(var.alarm_email)) > 0 ? 1 : 0
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# Minimal CloudWatch dashboard (JSON string)
resource "aws_cloudwatch_dashboard" "sentiment_dashboard" {
  dashboard_name = "aialpha-sentiment-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "text",
        x = 0, y = 0, width = 24, height = 1,
        properties = {
          markdown = "### Analysis metrics (namespace: ${var.namespace})"
        }
      }
    ]
  })
}

# Simple CloudWatch alarm on a custom metric "analysis.count" in provided namespace
resource "aws_cloudwatch_metric_alarm" "no_analysis_alarm" {
  alarm_name          = "aialpha-no-analysis-alarm"
  alarm_description   = "Alarm when analysis.count is 0 (no analyses processed)"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  threshold           = 1
  metric_name         = "analysis.count"
  namespace           = var.namespace
  period              = 300
  statistic           = "Sum"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}
