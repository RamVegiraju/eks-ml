# Deploying a FastAPI ML Translator to Amazon EKS

This project demonstrates how to deploy a **Hugging Face Transformers model** (`t5-small` English → French translator) behind a **FastAPI service** to an **Amazon EKS cluster**.  
We containerize the app, push it to **Amazon ECR**, and expose it via an **AWS Application Load Balancer (ALB)**.

---

## Repository Structure

├── app.py # FastAPI app (Hugging Face model)
├── Dockerfile # Container image definition
├── requirements.txt # Python dependencies
│
├── deployment.yaml # K8s Deployment spec
├── service.yaml # K8s Service spec (ALB-backed)
│
├── build_and_push.sh # Builds and pushes multi-arch image to ECR
├── create_cluster.sh # Creates EKS cluster and node group
├── setup_alb_controller.sh # Installs AWS Load Balancer Controller
├── fix_rbac_access.sh # Ensures IAM user/role has cluster-admin RBAC
├── invoke.sh # Helper script to test inference endpoint


## Step by Step Guide

Once you have your deployment.yaml and service.yaml appropriately configured:
```
# point to right cluster
aws eks update-kubeconfig --name ml-app-dept --region us-east-1

# verify nodes
kubectl get nodes

# create namespace
kubectl create namespace ml-demo
kubectl get ns

# apply deployment
kubectl apply -f deployment.yaml -n ml-demo
kubectl get pods -n ml-demo

# apply service
kubectl apply -f service.yaml -n ml-demo
kubectl get svc translator-service -n ml-demo -w #wait till external IP with AWS ELB DNS appears

# invoke
curl -X POST \
  http://<EXTERNAL-DNS>/translate \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello, how are you?"}'

# cleanup (optional)
kubectl delete -f service.yaml -n ml-demo
kubectl delete -f deployment.yaml -n ml-demo
kubectl delete namespace ml-demo
```