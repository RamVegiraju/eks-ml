#!/usr/bin/env bash
set -euo pipefail

CLUSTER="ml-app-dept"
AWS_REGION="us-east-1"

echo "🔑 Detecting current IAM identity..."
IAM_ARN=$(aws sts get-caller-identity --query "Arn" --output text)
echo "Using IAM principal: $IAM_ARN"

echo "📦 Creating/ensuring EKS access entry..."
aws eks create-access-entry \
  --cluster-name "$CLUSTER" \
  --principal-arn "$IAM_ARN" \
  --type STANDARD \
  --region "$AWS_REGION" || echo "ℹ️ Access entry may already exist, continuing..."

echo "🔗 Associating AmazonEKSClusterAdminPolicy..."
aws eks associate-access-policy \
  --cluster-name "$CLUSTER" \
  --principal-arn "$IAM_ARN" \
  --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
  --access-scope type=cluster \
  --region "$AWS_REGION" || echo "ℹ️ Policy may already be associated, continuing..."

echo "🔍 Verifying access entries..."
aws eks list-access-entries \
  --cluster-name "$CLUSTER" \
  --region "$AWS_REGION"

echo "✅ Done! Try running: kubectl get nodes"