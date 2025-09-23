#!/usr/bin/env bash
set -euo pipefail

# Config
CLUSTER=${CLUSTER:-ml-app-dept}
AWS_REGION=${AWS_REGION:-us-east-1}
POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"
SA_NAMESPACE="kube-system"
SA_NAME="aws-load-balancer-controller"
HELM_VERSION="1.13.0"

echo "🚀 Setting up AWS Load Balancer Controller for cluster: $CLUSTER in $AWS_REGION"

# 1. Ensure OIDC provider exists
echo "🔎 Checking OIDC provider..."
if ! eksctl get iamidentitymapping --cluster "$CLUSTER" --region "$AWS_REGION" >/dev/null 2>&1; then
  eksctl utils associate-iam-oidc-provider \
    --region "$AWS_REGION" \
    --cluster "$CLUSTER" \
    --approve
else
  echo "✅ OIDC provider already associated."
fi

# 2. Create IAM policy if missing
echo "🔎 Checking IAM policy..."
POLICY_ARN="arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/$POLICY_NAME"
if ! aws iam get-policy --policy-arn "$POLICY_ARN" >/dev/null 2>&1; then
  echo "📥 Downloading IAM policy JSON..."
  curl -s -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
  echo "🔑 Creating IAM policy..."
  aws iam create-policy --policy-name "$POLICY_NAME" --policy-document file://iam-policy.json
else
  echo "✅ IAM policy already exists: $POLICY_ARN"
fi

# 3. Create IAM service account if missing
echo "🔎 Checking service account..."
if ! kubectl get sa "$SA_NAME" -n "$SA_NAMESPACE" >/dev/null 2>&1; then
  echo "🔑 Creating IAM service account..."
  eksctl create iamserviceaccount \
    --cluster "$CLUSTER" \
    --namespace "$SA_NAMESPACE" \
    --name "$SA_NAME" \
    --attach-policy-arn "$POLICY_ARN" \
    --override-existing-serviceaccounts \
    --region "$AWS_REGION" \
    --approve
else
  echo "✅ Service account already exists."
fi

# 4. Install/upgrade Helm chart
echo "📦 Installing/Upgrading Helm chart..."
helm repo add eks https://aws.github.io/eks-charts >/dev/null 2>&1 || true
helm repo update >/dev/null 2>&1

VPC_ID=$(aws eks describe-cluster \
  --name "$CLUSTER" \
  --region "$AWS_REGION" \
  --query "cluster.resourcesVpcConfig.vpcId" \
  --output text)

helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n "$SA_NAMESPACE" \
  --set clusterName="$CLUSTER" \
  --set serviceAccount.create=false \
  --set serviceAccount.name="$SA_NAME" \
  --set region="$AWS_REGION" \
  --set vpcId="$VPC_ID" \
  --version "$HELM_VERSION"

# 5. Tag all subnets in VPC
echo "🏷️ Tagging subnets..."
SUBNET_IDS=$(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query "Subnets[].SubnetId" \
  --region "$AWS_REGION" \
  --output text)

aws ec2 create-tags \
  --resources $SUBNET_IDS \
  --region "$AWS_REGION" \
  --tags Key=kubernetes.io/cluster/$CLUSTER,Value=owned \
         Key=kubernetes.io/role/elb,Value=1

# 6. Verify
echo "🔍 Verifying controller pods..."
kubectl rollout status deployment/aws-load-balancer-controller -n "$SA_NAMESPACE"

# kubectl get pods -n "kube-system" | grep aws-load-balancer-controller
kubectl get pods -n "$SA_NAMESPACE" | grep aws-load-balancer-controller

echo "🎉 AWS Load Balancer Controller setup complete!"
