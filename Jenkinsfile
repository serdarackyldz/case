pipeline {
    agent {
        kubernetes {
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
    image: sserdaracikyildiz/registry-1:base
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
        }
    }
    environment {
        DOCKER_IMAGE = "sserdaracikyildiz/registry-1:pythonapp"
        KUBE_CONFIG = credentials('kubeconfig') // Jenkins credential ID for kubeconfig
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
                        def app = docker.build("sserdaracikyildiz/registry-1:${env.BUILD_ID}")
                    }
                }
                script {
                    docker.build("${DOCKER_IMAGE}:${env.BUILD_ID}")
                }
            }
        }
        stage('Test') {
            steps {
                container('docker') {
                    // Run steps inside Docker container
                    script {
                        // Run tests
                        docker.image("${DOCKER_IMAGE}:${env.BUILD_ID}").inside {
                            sh 'curl flask-app.default:80'
                        }
                    }
                }
                script {
                    container('docker') {
                        docker.image("${DOCKER_IMAGE}:${env.BUILD_ID}").inside {
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
                        docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                            def app = docker.image("${DOCKER_IMAGE}:${env.BUILD_ID}")
                            app.push("${env.BUILD_ID}")
                            app.push("latest")
                        }
                    }
                }
                script {
                    container('docker') {
                        docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                            def app = docker.image("${DOCKER_IMAGE}:${env.BUILD_ID}")
                            app.push("${env.BUILD_ID}")
                            app.push("latest")
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
                        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                            sh 'kubectl apply -f k8s/deployment.yaml -n default'
                            sh 'kubectl apply -f k8s/service.yaml -n default'
                        }
                    }
                }
                script {
                    container('kubectl') {
                        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                            sh 'kubectl apply -f k8s/deployment.yaml -n default'
                            sh 'kubectl apply -f k8s/service.yaml -n default'
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
