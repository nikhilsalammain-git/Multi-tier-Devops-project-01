# Flask Kubernetes manifests

Build and push the Flask image to ECR, then replace the image value in
`deployment.yaml` with the complete ECR image URI.

Create the real Secret separately. Replace the placeholder values with your RDS
credentials and endpoint; do not commit the command or the generated Secret:

```bash
kubectl create namespace flask-app --dry-run=client -o yaml | kubectl apply -f -
kubectl -n flask-app create secret generic flask-db-secret \
  --from-literal='DB_URL=postgresql://USER:PASSWORD@RDS_ENDPOINT:5432/DATABASE' \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -k .
```

Do not commit `secret.yaml` or real database credentials. The committed
`secret.example.yaml` is only a template.

Check the deployment and service:

```bash
kubectl -n flask-app rollout status deployment/flask-app
kubectl -n flask-app get service flask-app
```