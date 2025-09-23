#!/bin/bash
set -euo pipefail

AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="474422712127" #replace with your account ID
REPO_NAME="ml-translator-app" #replace with your ECR repo name
IMAGE_TAG="v1"
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_TAG}"

echo "🔑 Logging in to ECR..."
aws ecr get-login-password --region "$AWS_REGION" | \
  docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "📦 Ensuring repo exists: $REPO_NAME"
aws ecr describe-repositories --repository-names "$REPO_NAME" --region "$AWS_REGION" >/dev/null 2>&1 || \
  aws ecr create-repository --repository-name "$REPO_NAME" --region "$AWS_REGION"

echo "🐳 Building multi-arch image..."
docker buildx create --use --name multiarch-builder >/dev/null 2>&1 || true
docker buildx use multiarch-builder

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t "$ECR_URI" \
  --push .

echo "🔍 Checking manifest..."
docker buildx imagetools inspect "$ECR_URI"