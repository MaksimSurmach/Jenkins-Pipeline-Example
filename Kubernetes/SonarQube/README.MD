**Install via helm**
```bash
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update
kubectl create namespace sonarqube
helm upgrade --install -n sonarqube sonarqube sonarqube/sonarqube
```

**Install via deployment**
```bash
kubectl apply -f deploy.yaml
kubectl apply -f ingress.yaml
kubectl apply -f postgres-vpc.yaml
kubectl apply -f postgress-app.yaml
kubectl apply -f pvc.yaml
```