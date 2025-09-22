aws ecr describe-repositories --region us-east-1 --repository-names eks-ml-app
aws ecr describe-images --region us-east-1 --repository-name eks-ml-app \
  --image-ids imageTag=latest