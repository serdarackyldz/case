pipeline {
    agent {
        any {
            cloud 'default'
            defaultContainer 'docker'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: pipeline
spec:
  containers:
  - name: docker
    image: docker:dind
    command:
    - cat
    tty: true
    securityContext:
      privileged: true  
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
"""
        }  
    }  
    environment {
        DOCKER_IMAGE = "sserdaracikyildiz/registry-1:pythonapp"
        KUBE_CONFIG = credentials('kubeconfig') // Jenkins credential ID for kubeconfig
        TAG = "latest"
    }
    stages {
        stage('Checkout') {
            steps {
                // Checkout the code from version control
                checkout scm
            }
        }
        stage('Build') {
            steps {
                container('docker') {
                    // Run steps inside Docker container
                    script {
                        // Build the Docker image
                        sh "docker build -t sserdaracikyildiz/registry-1:serdar ."
                    }
                }
            }
        }
        stage('Test') {
            steps {
                container('docker') {
                    // Run steps inside Docker container
                    script {
                        // Run tests
                        //docker.image("${DOCKER_IMAGE}:${env.BUILD_ID}").inside {
                            sh 'curl flask-app.default:80'
                        }
                    }
                }
            }
        }
        stage('Push to Registry') {
            steps {
                container('docker') {
                    // Run steps inside Docker container
                    script {
                        // Push the Docker image to a Docker registry
                        sh "docker login -u sserdaracikyildiz -p Serdar96."
                        sh "docker push sserdaracikyildiz/registry-1:serdar"
                        }
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    // Run steps inside kubectl container
                    script {
                        // Use Kubernetes CLI to apply deployment and service manifests
                        sh "kubectl set image deployment/flask-app flask-app=sserdaracikyildiz/registry-1:serdar"
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            // Clean up resources if needed
            echo 'Cleaning up resources...'
        }
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
