#!/bin/bash
set -euo pipefail

# ===== CONFIG =====
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="474422712127"
REPO_NAME="eks-ml-app"
IMAGE_TAG="latest"
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:${IMAGE_TAG}"

# ===== LOGIN TO ECR =====
echo "🔑 Logging into Amazon ECR..."
aws ecr get-login-password --region "$AWS_REGION" | \
  docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# ===== CREATE REPO IF NOT EXISTS =====
echo "📦 Ensuring ECR repo exists: $REPO_NAME"
aws ecr describe-repositories --repository-names "$REPO_NAME" --region "$AWS_REGION" >/dev/null 2>&1 || \
  aws ecr create-repository --repository-name "$REPO_NAME" --region "$AWS_REGION"

# ===== BUILD AND PUSH MULTI-ARCH IMAGE =====
echo "🐳 Building and pushing multi-arch Docker image: $ECR_URI"
docker buildx create --use --name multiarch-builder >/dev/null 2>&1 || true
docker buildx use multiarch-builder

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t "$ECR_URI" \
  --push .

# ===== VERIFY MANIFEST =====
echo "🔍 Verifying manifest for $ECR_URI"
docker buildx imagetools inspect "$ECR_URI" || docker manifest inspect "$ECR_URI"