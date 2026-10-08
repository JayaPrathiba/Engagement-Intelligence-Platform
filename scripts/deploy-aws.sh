#!/usr/bin/env bash
set -euo pipefail

# ─── HOPE Platform — Simple AWS Deployment ───────────────────────────────────
# Deploys CloudFormation stack (EC2 free tier + Docker Compose)
# The EC2 instance auto-clones the repo and starts the app.
#
# Prerequisites:
#   - AWS CLI configured
#   - An EC2 key pair already created in AWS console
#
# Usage:
#   ./scripts/deploy-aws.sh <key-pair-name>
# ─────────────────────────────────────────────────────────────────────────────

REGION="${AWS_REGION:-us-east-1}"
STACK_NAME="hope-platform"
KEY_PAIR="${1:?Usage: ./scripts/deploy-aws.sh <key-pair-name>}"

echo ">> Deploying HOPE Platform to AWS ($REGION)..."
echo ">> Using key pair: $KEY_PAIR"

aws cloudformation deploy \
  --region "$REGION" \
  --stack-name "$STACK_NAME" \
  --template-file infra/cloudformation/hope-infrastructure.yml \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides "KeyPairName=$KEY_PAIR"

echo ""
echo ">> Stack deployed! Getting outputs..."

aws cloudformation describe-stacks \
  --region "$REGION" \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs[*].[Description,OutputValue]" \
  --output table

echo ""
echo ">> App will be ready in ~3-5 minutes (Docker needs to build)."
echo ">> Push changes to GitHub → app auto-updates within 2 minutes."
