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
    image: sserdaracikyildiz/registry-1:baseimage
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
        // Add more stages as needed
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
