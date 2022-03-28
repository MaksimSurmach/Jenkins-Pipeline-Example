pipeline {
    agent any
    environment {
        imageName = 'helloworld-msurmach'
        registryCredentials = "nexus"
        registry = "eu.gcr.io"
        err_msg = ' '
    }
    tools { 
        maven 'maven3' 
    }
    stages {
        stage('Preparation')  {
            steps{
                script{
                    try {
                        git branch: 'main',
                            url: 'https://github.com/MaksimSurmach/Jenkins-Pipeline-Example.git'
                    } catch (e) {
                        err_msg = "${e}"
                        throw e
                    }   
                }
            }
        }
        
        stage('Building code') {
            steps {
                script{
                    try {
                        sh 'mvn package -DskipTests'
                    } catch (e) {
                        err_msg = "${e}"
                        throw e
                    }   
                }
            }
        }
        stage('Sonar scan') { 
            steps {
                script{
                    try {
                       echo """ 
                        withSonarQubeEnv('Sonar') {
                            sh "/var/jenkins_home/tools/hudson.plugins.sonar.SonarRunnerInstallation/Sonar/bin/sonar-scanner -Dsonar.host.url=<SONAR_URL>  -Dsonar.projectKey=FinalTaskTest -Dsonar.projectName=FinalTaskTest -Dsonar.language=java -Dsonar.qualitygate.wait=true -Dsonar.projectVersion=1.0 -Dsonar.java.binaries=target -Dsonar.sources=src/main/ -Dsonar.tests=src/test/ "
                        }
                        """
                    } catch (e) {
                        err_msg = "${e}"
                        throw e
                    }   
                }
            }
        }
        stage('Testing') { 
            parallel{
                stage('pre-integration-test') {
                    steps{
                            script{
                                try {
                                   sh 'mvn pre-integration-test' 
                                } catch (e) {
                                    err_msg = "${e}"
                                    throw e
                                }   
                            }
                    } 
                }
                stage('integration-test') {
                    steps{
                            script{
                                try {
                                   sh 'echo mvn integration-test' 
                                } catch (e) {
                                    err_msg = "${e}"
                                    throw e
                                }   
                            }
                    }
                }
                stage('post-integration-test') {
                    steps{
                            script{
                                try {
                                    sh ' echo mvn post-integration-test' 
                                } catch (e) {
                                    err_msg = "${e}"
                                    throw e
                                }   
                            }
                    }
                }
            }
        }

        stage('Triggering job and fetching artefact after finishing') {
          steps{
                script {
                    try {
                        build job: 'MNTLAB-msurmach-child1-build-job', 
                          parameters: [
                            string(name: 'BRANCH_NAME', value: 'main')
                          ],
                          wait : true
                          
                          copyArtifacts filter: '*.log', fingerprintArtifacts: true, projectName: 'MNTLAB-msurmach-child1-build-job'
            
                
                      }
                      catch (e){
                        err_msg = "${e}"
                        throw e
                      }
                  
                }
          }
        }
        stage('Packaging and Publishing results') {
          parallel {
            stage('Archiving artefact') {
              steps{
                script{
                  try{
                    sh "tar -czf pipeline-msurmach-${env.BUILD_NUMBER}.tar.gz child1.log target/helloworld-ws.war Jenkinsfile"
                         nexusArtifactUploader(
                            nexusVersion: "nexus3",
                            protocol: "http",
                            nexusUrl: "10.12.1.14:8081",
                            groupId: "ft",
                            version: "${env.BUILD_NUMBER}",
                            repository: "mvn2",
                            credentialsId: registryCredentials,
                            artifacts: [
                                [artifactId: "pipeline-msurmach",
                                classifier: '',
                                file: "pipeline-msurmach-${env.BUILD_NUMBER}.tar.gz",
                                type: 'tar.gz']
                            ]
                        );
                  }
                  catch (e){
                    err_msg = "${e}"
                    throw e
                  } 
                }
              }
            }
    
            stage('Creating Docker image') {
              steps{
                script{
                  try{
                     dockerImage = docker.build "gcr.io/personal-342719/helloworld-msurmach:rc-${env.BUILD_NUMBER}"
                     withDockerRegistry([credentialsId: "gcr:personal-342719", url: "https://gcr.io"]) {
                        sh "docker push gcr.io/personal-342719/helloworld-msurmach:rc-${env.BUILD_NUMBER}"
                      }
                  }
                  catch (e){
                    err_msg = "${e}"
                    throw e
                  } 
                }
              }
            }
          }
        }
        stage('Asking for manual approval') {
            steps {
                script {
                    timeout(time:180, unit:'SECONDS') {
                        env.APPROVE_PROD = input message: 'Deploy to Production', ok: 'Continue'
                    }
                }
            }
        }
        stage('Deployment ') {
            steps{
                script {
                    sh "sed -i -e 's,<BUILD>,${env.BUILD_NUMBER},g' deploy_app.yaml"
                    kubernetesDeploy(configs: "deploy_app.yaml", kubeconfigId: "k8s_kubeconfig")
                }
                
            }
        }
    }
    
    post {
        success {
            emailext (
              to: 'maxsurm@gmail.com',
              subject: "Pipiline complete: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
              body: """Job ${env.BUILD_NUMBER} succesfu finish""",
              recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }
        failure {
          emailext (
              to: 'maxsurm@gmail.com',
              subject: "Failed: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
              body: """Failed Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' 
ERROR:
${err_msg}""",
              attachLog: true ,
              recipientProviders: [[$class: 'DevelopersRecipientProvider']]
            )
        }
  }
}