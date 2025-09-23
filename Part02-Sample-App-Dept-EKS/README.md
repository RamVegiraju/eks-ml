# Deploying a FastAPI ML Translator to Amazon EKS

This project demonstrates how to deploy a **Hugging Face Transformers model** (`t5-small` English → French translator) behind a **FastAPI service** to an **Amazon EKS cluster**.  
We containerize the app, push it to **Amazon ECR**, and expose it via an **AWS Application Load Balancer (ALB)**.

---

This project demonstrates deploying a Hugging Face Transformer model with FastAPI to Amazon EKS.  
It includes infrastructure setup, containerization, Kubernetes manifests, and helper scripts.

## Files

- **app.py** – FastAPI application serving a Hugging Face model.  
- **Dockerfile** – Multi-architecture container image definition.  
- **requirements.txt** – Python dependencies.  
- **deployment.yaml** – Kubernetes Deployment specification.  
- **service.yaml** – Kubernetes Service specification (ALB-backed).  
- **build_and_push.sh** – Builds and pushes the image to Amazon ECR.  
- **create_cluster.sh** – Creates an Amazon EKS cluster and node group.  
- **setup_alb_controller.sh** – Installs the AWS Load Balancer Controller.  
- **fix_rbac_access.sh** – Ensures IAM user/role has cluster-admin access.  
- **invoke.sh** – Helper script to test the inference endpoint.  
- **README.md** – Project documentation.  

---

## Kubernetes Fundamentals

- **Namespace**  
  Logical grouping for resources. Example: `ml-demo` keeps your ML app isolated.  

- **Deployment**  
  Defines how many replicas (pods) should run, what image to use, and manages scaling and rolling updates.  

- **Pods**  
  The smallest compute unit in Kubernetes. Each pod wraps your FastAPI container with the Hugging Face model.  

- **Service**  
  Provides stable networking and load balancing across pods.  
  - In this project, a `LoadBalancer` type Service provisions an AWS ALB, giving you an external DNS endpoint to access your app. 

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