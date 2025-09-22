#!/bin/bash
ALB=$(kubectl get svc ml-fastapi -n ml-demo -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Testing FastAPI at: $ALB"

curl -X POST \
  http://$ALB/translate \
  -H "Content-Type: application/json" \
  -d '{"text":"Hello from EKS!"}'