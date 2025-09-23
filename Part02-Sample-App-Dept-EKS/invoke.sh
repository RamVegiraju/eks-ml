curl -X POST \
  http://k8s-mldemo-translat-3f8933f89f-a986b5e5fbcf8503.elb.us-east-1.amazonaws.com/translate \
  -H "Content-Type: application/json" \
  -d '{"text": "Hello, how are you?"}'