#!/bin/bash
kubectl get svc ml-fastapi -n ml-demo
kubectl describe svc ml-fastapi -n ml-demo | grep -A5 Events