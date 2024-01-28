pipeline {
    agent any

    environment {
        AWS_REGION          = 'us-east-1'
        AWS_CREDENTIALS_ID  = 'ff92258b-6616-45e7-bbe6-275f6f46be5a'
        AWS_CREDENTIALS_ID2 = 'ff92258b-6616-45e7-bbe6-275f6f46be5a'
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
            }
        }

        stage('Prepare Image Tag') {
            steps {
                script {
                    // Gerando uma tag única com base no hash do commit do Git e atualizando a variável de ambiente
                    def imageTag = "minha-aplicacao-java-${env.GIT_COMMIT}"
                    env.IMAGE_TAG = "${REGISTRY_URI}:${imageTag}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${env.IMAGE_TAG}")
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
                        // Primeiro, tag a imagem com o URI do repositório ECR
                        sh "docker tag ${env.IMAGE_TAG} ${REGISTRY_URI}:${env.GIT_COMMIT}"

                        // Em seguida, faça o push da imagem para o repositório ECR
                        sh "docker push ${REGISTRY_URI}:${env.GIT_COMMIT}"
                    }
                }
            }
        }

        stage('Checkout Terraform Code') {
            steps {
                git(
                    credentialsId: 'c6a9147b-1d40-4cc0-9d29-979e3dfb8048', 
                    url: "${REPO_TERRAFORM}",
                    branch: 'main'              
                )
            }
        }

        stage('Terraform Init and Apply') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: AWS_CREDENTIALS_ID]]) {
                        sh "terraform init"
                        sh "terraform apply -auto-approve -var 'docker_image=${environment.IMAGE_TAG}'"
                    }
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

