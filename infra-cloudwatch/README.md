infra-cloudwatch
================

Inneholder Terraform-eksempel for:
 - SNS topic (alerts) + optional email subscription
 - CloudWatch Dashboard
 - CloudWatch Alarm (analysis.count < 1 -> ALARM)

Lokale test-kommandoer (bruk Docker for Terraform):
  docker run --rm -v "$PWD":/repo -w /repo/infra-cloudwatch hashicorp/terraform:1.5.7 init -backend=false
  docker run --rm -e AWS_ACCESS_KEY_ID=LOCALFAKEKEY -e AWS_SECRET_ACCESS_KEY=LOCALFAKESECRET -e AWS_DEFAULT_REGION=eu-west-1 -v "$PWD":/repo -w /repo/infra-cloudwatch hashicorp/terraform:1.5.7 plan

For å apply mot ekte AWS må du ha gyldige credentials i miljøet eller secrets i CI.

OBS: Du må tilpasse metrikknavn (f.eks. "analysis.count", "analysis.latency") i filene dersom applikasjonen sender andre metrikknavn.
