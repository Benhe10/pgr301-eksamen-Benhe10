#!/usr/bin/env bash
set -euo pipefail
mkdir -p media

echo "== Terraform: infra-s3 (init & plan with fake creds) =="
docker run --rm -v "$PWD":/repo -w /repo/infra-s3 hashicorp/terraform:1.5.7 init -backend=false > media/terraform-init-infra-s3.txt 2>&1 || true
docker run --rm -e AWS_ACCESS_KEY_ID=LOCALFAKEKEY -e AWS_SECRET_ACCESS_KEY=LOCALFAKESECRET -e AWS_DEFAULT_REGION=eu-west-1 -v "$PWD":/repo -w /repo/infra-s3 hashicorp/terraform:1.5.7 plan -out=tfplan > media/terraform-plan-infra-s3.txt 2>&1 || true
docker run --rm -v "$PWD":/repo -w /repo/infra-s3 hashicorp/terraform:1.5.7 show -no-color tfplan > media/terraform-plan-infra-s3-readable.txt 2>&1 || true

echo "== Terraform: infra-cloudwatch (init & plan with fake creds) =="
docker run --rm -v "$PWD":/repo -w /repo/infra-cloudwatch hashicorp/terraform:1.5.7 init -backend=false > media/terraform-init-infra-cloudwatch.txt 2>&1 || true
docker run --rm -e AWS_ACCESS_KEY_ID=LOCALFAKEKEY -e AWS_SECRET_ACCESS_KEY=LOCALFAKESECRET -e AWS_DEFAULT_REGION=eu-west-1 -v "$PWD":/repo -w /repo/infra-cloudwatch hashicorp/terraform:1.5.7 plan -out=tfplan > media/terraform-plan-infra-cloudwatch.txt 2>&1 || true
docker run --rm -v "$PWD":/repo -w /repo/infra-cloudwatch hashicorp/terraform:1.5.7 show -no-color tfplan > media/terraform-plan-infra-cloudwatch-readable.txt 2>&1 || true

echo "== SAM: build using Docker build image =="
# Builds sam artifacts into sam-comprehend/.aws-sam (uses public build image)
docker run --rm -v "$PWD":/work -w /work/sam-comprehend public.ecr.aws/sam/build-python3.11:latest bash -lc "sam build" > media/sam-build-docker.txt 2>&1 || true

echo "== SAM: quick 'invoke' test using lambda base image (attempt) =="
if [ -d sam-comprehend/.aws-sam/build/SentimentAnalysisFunction ]; then
  docker run --rm -v "$PWD"/sam-comprehend/.aws-sam/build/SentimentAnalysisFunction:/var/task public.ecr.aws/lambda/python:3.11 bash -lc "python -c 'import app; print(\"handler ok, callable:\", hasattr(app, \"lambda_handler\"))'" > media/sam-local-docker-invoke.txt 2>&1 || true
else
  echo "SAM build artifacts not found; see media/sam-build-docker.txt" > media/sam-local-docker-invoke.txt
fi

echo "== Docker: build sentiment image =="
(cd sentiment-docker && docker build -t aialpha-sentiment:local .) > media/docker-build.txt 2>&1 || true

echo "== Docker: run smoke test script =="
chmod +x sentiment-docker/run_smoketest.sh || true
sentiment-docker/run_smoketest.sh > media/docker-smoketest.txt 2>&1 || true

echo "== Docker: run container (metrics disabled) and capture health/logs =="
docker rm -f aialpha-sentiment-local 2>/dev/null || true
docker run -d -p 8080:8080 -e MANAGEMENT_METRICS_EXPORT_CLOUDWATCH_ENABLED=false --name aialpha-sentiment-local aialpha-sentiment:local > /dev/null 2>&1 || true
sleep 3
curl -fsS http://127.0.0.1:8080/actuator/health > media/docker-health.txt 2>&1 || true
docker logs aialpha-sentiment-local --tail 400 > media/docker-running-logs.txt 2>&1 || true
docker rm -f aialpha-sentiment-local 2>/dev/null || true

echo "== push_metric script help via docker (verifiser dependency) =="
docker run --rm -v "$PWD":/work -w /work python:3.11-slim bash -lc "pip install boto3 >/dev/null 2>&1 || true; python scripts/push_test_metric.py --help" > media/push_metric-help-docker.txt 2>&1 || true

echo "DONE. Collected logs in media/ (see files)."
