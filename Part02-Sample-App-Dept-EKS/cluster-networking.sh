#!/bin/bash

# Variables
CLUSTER=hello-world
REGION=us-east-1

# Get VPC ID
VPC_ID=$(aws eks describe-cluster \
  --name "$CLUSTER" \
  --region "$REGION" \
  --query "cluster.resourcesVpcConfig.vpcId" \
  --output text)

# Get Subnet IDs
SUBNET_IDS=$(aws eks describe-cluster \
  --name "$CLUSTER" \
  --region "$REGION" \
  --query "cluster.resourcesVpcConfig.subnetIds[]" \
  --output text)

echo "VPC: $VPC_ID"
echo "SUBNETS:"
echo "$SUBNET_IDS"

# Tag all subnets for this cluster
for subnet in $SUBNET_IDS; do
  echo "Tagging subnet $subnet ..."
  aws ec2 create-tags \
    --resources "$subnet" \
    --region "$REGION" \
    --tags \
      Key="kubernetes.io/cluster/$CLUSTER",Value="owned" \
      Key="kubernetes.io/role/elb",Value="1"
done

# Verify tagging
aws ec2 describe-subnets \
  --subnet-ids $SUBNET_IDS \
  --region "$REGION" \
  --query 'Subnets[].{id:SubnetId,tags:Tags}' \
  --output table
