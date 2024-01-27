pipeline {
    agent any

    environment {
        REGISTRY_URI = '290356906676.dkr.ecr.us-east-1.amazonaws.com/myrepo'
        IMAGE_TAG = 'minha-aplicacao-java:latest'
        AWS_REGION = 'us-east-1'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_TAG}")
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                script {
                    // Utiliza as credenciais da AWS configuradas no servidor
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${REGISTRY_URI}"
                }
            }
        }

        stage('Push Image to ECR') {
            steps {
                script {
                    docker.withRegistry("https://${REGISTRY_URI}") {
                        docker.image("${IMAGE_TAG}").push()
                    }
                }
            }
        }
    }
}

