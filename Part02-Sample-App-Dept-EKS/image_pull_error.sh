kubectl get pods -n ml-demo -l app=ml-fastapi -o wide
POD=$(kubectl get pods -n ml-demo -l app=ml-fastapi -o jsonpath='{.items[0].metadata.name}')
kubectl describe pod -n ml-demo $POD | sed -n '/Events/,$p'