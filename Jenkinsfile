pipeline {
    agent {
        kubernetes {
            cloud 'default'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: pipeline
spec:
  containers:
  - name: docker
    image: docker:latest
    command:
    - cat
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
                checkout scm
            }
        }
        stage('Build') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${env.BUILD_ID}")
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    docker.image("${DOCKER_IMAGE}:${env.BUILD_ID}").inside {
                        sh 'curl flask-app.default:80'
                    }
                }
            }
        }
        stage('Push to Registry') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        def app = docker.image("${DOCKER_IMAGE}:${env.BUILD_ID}")
                        app.push("${env.BUILD_ID}")
                        app.push("latest")
                    }
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                        sh 'kubectl apply -f k8s/deployment.yaml -n default'
                        sh 'kubectl apply -f k8s/service.yaml -n default'
                    }
                }
            }
        }
    }
    post {
        always {
            sh 'docker system prune -f'
        }
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
