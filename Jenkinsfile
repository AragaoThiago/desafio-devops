pipeline {
    agent any

    environment {
        REGISTRY_URI = '290356906676.dkr.ecr.us-east-1.amazonaws.com/myrepo'
        IMAGE_TAG = 'minha-aplicacao-java:latest'
        AWS_REGION = 'us-east-1'
        AWS_CREDENTIALS_ID = 'ff92258b-6616-45e7-bbe6-275f6f46be5a'
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
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS_ID]]) {
                        sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${REGISTRY_URI}"
                    }
                }
            }
        }

        stage('Push Image to ECR') {
            steps {
                script {
                    docker.withRegistry("https://${REGISTRY_URI}", AWS_CREDENTIALS_ID) {
                        docker.image("${IMAGE_TAG}").push()
                    }
                }
            }
        }
    }
}

