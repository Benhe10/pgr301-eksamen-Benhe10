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
  region = var.region
  # For local planning without credentials, run Terraform inside Docker
  # with fake creds or set AWS_* env vars in your shell.
}

# SNS topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "aialpha-alerts"
}

# optional email subscription (only created if alarm_email != "")
resource "aws_sns_topic_subscription" "email" {
  count = length(trimspace(var.alarm_email)) > 0 ? 1 : 0
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# CloudWatch dashboard (simple JSON with placeholder widgets)
resource "aws_cloudwatch_dashboard" "sentiment_dashboard" {
  dashboard_name = "aialpha-sentiment-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x = 0,
        y = 0,
        width = 24,
        height = 6,
        properties = {
          metrics = [
            [ "${var.namespace}", "analysis.count" ],
            [ ".", "analysis.latency" ]
          ],
          period = 300,
          stat = "Sum",
          title = "Analysis count & latency (namespace: ${var.namespace})"
        }
      }
    ]
  })
}

# Example alarm: trigger when analysis count < 1 for 1 datapoint (synthetic)
resource "aws_cloudwatch_metric_alarm" "no_analysis_alarm" {
  alarm_name          = "aialpha-no-analysis"
  alarm_description   = "Alarm when analysis.count < 1"
  namespace           = var.namespace
  metric_name         = "analysis.count"
  comparison_operator = "LessThanThreshold"
  threshold           = 1
  evaluation_periods  = 1
  period              = 300
  statistic           = "Sum"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
}
