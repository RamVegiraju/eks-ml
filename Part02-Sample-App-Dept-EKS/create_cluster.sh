export AWS_REGION=us-east-1
export AWS_ACCOUNT_ID=474422712127
export CLUSTER=ml-app-dept

eksctl create cluster \
  --name "$CLUSTER" \
  --region "$AWS_REGION" \
  --managed \
  --nodes 3 \
  --node-type t3.large \
  --with-oidc