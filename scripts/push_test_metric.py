#!/usr/bin/env python3
"""
Push a test metric to CloudWatch. Works against LocalStack if --endpoint provided.
Usage:
  python3 scripts/push_test_metric.py --endpoint http://localhost:4566
"""
import argparse
import boto3
import time

parser = argparse.ArgumentParser()
parser.add_argument('--endpoint', help='AWS endpoint (for LocalStack), eg http://localhost:4566', default=None)
parser.add_argument('--namespace', help='Metric namespace', default='AiAlpha')
parser.add_argument('--name', help='Metric name', default='TestMetric')
parser.add_argument('--value', help='Metric value', type=float, default=1.0)
args = parser.parse_args()

session_kwargs = {}
if args.endpoint:
    session = boto3.session.Session()
    cw = session.client('cloudwatch', endpoint_url=args.endpoint, region_name='us-east-1')
else:
    cw = boto3.client('cloudwatch')

print(f"Pushing metric {args.name}={args.value} to namespace {args.namespace} (endpoint={args.endpoint})")
resp = cw.put_metric_data(
    Namespace=args.namespace,
    MetricData=[
        {
            'MetricName': args.name,
            'Timestamp': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
            'Value': args.value,
            'Unit': 'Count'
        }
    ]
)
print("Sent:", resp)
