pipeline {
    agent {
        kubernetes {
            yaml """
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: docker
                image: docker:19.03.12
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
                // Checkout the code from version control
                checkout scm
            }
        }

        stage('Build') {
            steps {
                container('docker') {
                    script {
                        // Build the Docker image
                        def app = docker.build("${DOCKER_IMAGE}:${env.BUILD_ID}")
                    }
                }
            }
        }

        stage('Test') {
            steps {
                container('docker') {
                    script {
                        // Run tests
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
                    script {
                        // Push the Docker image to a Docker registry
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
                    script {
                        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                            sh 'kubectl apply -f k8s/deployment.yaml'
                            sh 'kubectl apply -f k8s/service.yaml'
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            container('docker') {
                // Clean up resources
                sh 'docker system prune -f'
            }
        }
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
