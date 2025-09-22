CLUSTER=hello-world
REGION=us-east-1
VPC_ID=$(aws eks describe-cluster --name "$CLUSTER" --region "$REGION" \
  --query "cluster.resourcesVpcConfig.vpcId" --output text)
SUBNET_IDS=$(aws eks describe-cluster --name "$CLUSTER" --region "$REGION" \
  --query "cluster.resourcesVpcConfig.subnetIds[]" --output text)

# Show tags on the cluster subnets
aws ec2 describe-subnets --subnet-ids $SUBNET_IDS --region "$REGION" \
  --query 'Subnets[].{SubnetId:SubnetId,AZ:AvailabilityZone,Tags:Tags}' --output table

# Confirm which of those are PUBLIC (need at least two for internet-facing ELB)
aws ec2 describe-route-tables --filters Name=association.subnet-id,Values=''"$(echo $SUBNET_IDS | tr '\t' ',')"'' \
  --region "$REGION" --query 'RouteTables[].{RouteTableId:RouteTableId,Routes:Routes}' --output table