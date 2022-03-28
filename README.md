# Jenkins-Pipeline-Example
Jenkins Continuous Delivery pipeline job with:

 1. Clone code from git repo
 2. Build java code with Maven
 3. Run SonarQube test
 4. Parallels integration testing
 5. Trigger another job
 6. Archive artefact, log and jenkinsfile and upload to nexus artefact storage
 7. Build docker image and push to private registry 
 8. Manual approval to deploy in Kubernetes cluster (GKE)
  
## Configure Kubernetes

Folder "Kubernetes" include deployment for Nexus, Jenkins, SonarQube

## Configure Kubernetes deploy in Jenkins

Based on plugin [Kubernetes Continuous Deploy](https://plugins.jenkins.io/kubernetes-cd) 2.1.1
Create credentials from kube config file (~/.kube/config) 
```
kubernetesDeploy(configs: "<YAML_DEPLOY>", kubeconfigId: "<CREDENTIAL_ID>")
```

## Issue

 - SonarQube fail to install. 
 - SonarQube stage not work
 - SSL secure issue to pull image from nexus docker registry. Changed to GKR(Google Container Registry)