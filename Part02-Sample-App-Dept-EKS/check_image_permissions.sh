CLUSTER=hello-world
REGION=us-east-1
NG=$(aws eks list-nodegroups --cluster-name $CLUSTER --region $REGION --query 'nodegroups[0]' --output text)
ROLE_ARN=$(aws eks describe-nodegroup --cluster-name $CLUSTER --nodegroup-name $NG --region $REGION --query 'nodegroup.nodeRole' --output text)
ROLE_NAME=${ROLE_ARN##*/}

aws iam list-attached-role-policies --role-name $ROLE_NAME --query 'AttachedPolicies[].PolicyName'
# If missing, attach:
aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly