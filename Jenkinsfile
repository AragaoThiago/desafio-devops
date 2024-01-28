pipeline {
    agent any

    environment {
        AWS_REGION          = 'us-east-1'
        AWS_CREDENTIALS_ID  = 'ff92258b-6616-45e7-bbe6-275f6f46be5a'
        REPO_TERRAFORM      = 'https://github.com/AragaoThiago/terraform-devops.git'
        REGISTRY_URI        = '158355329422.dkr.ecr.us-east-1.amazonaws.com/devops'
        IMAGE_TAG           = ''
        ECS_CLUSTER         = 'desafio-cluster'
        ECS_SERVICE         = 'app'

    }

    stages {
        stage('Checkout App Code') {
            steps {
                checkout scm
                script {
                    IMAGE_TAG = "minha-aplicacao-java-${env.GIT_COMMIT}" // Gerando uma tag única
                    environment.IMAGE_TAG = "${REGISTRY_URI}:${IMAGE_TAG}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${environment.IMAGE_TAG}")
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

        stage('Push to AWS ECR') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS_ID]]) {
                        sh "docker push ${environment.IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Checkout Terraform Code') {
            steps {
                git(
                    credentialsId: 'c6a9147b-1d40-4cc0-9d29-979e3dfb8048', 
                    url: "${REPO_TERRAFORM}"                 
                )
            }
        }

        stage('Terraform Init and Apply') {
            steps {
                script {
                    sh "terraform init"
                    sh "terraform apply -auto-approve"
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS_ID]]) {
                        sh "aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --force-new-deployment"
                    }
                }
            }
        }
    }
}

