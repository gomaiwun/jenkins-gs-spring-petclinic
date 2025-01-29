pipeline {
    agent any
    parameters {
        string(name: 'VERSION', defaultValue: '1.0.0', description: 'Enter the version for the Docker image.')
    }
    environment {
        // Project parameters - replace with your actual values
        IMAGE_NAME = "gomaiwun/demo-application:${params.VERSION}" // Docker repository image name with tag
        EC2_USER = 'ubuntu' // Your EC2 username
        EC2_HOST = '34.205.72.138' // Your EC2 instance IP or hostname
        REMOTE_PATH = '/home/ubuntu' // Path on EC2 where you want to deploy
        DOCKER_CREDENTIALS = credentials('docker-credentials-id') // Docker credentials ID
        EC2_KEY = credentials('ubuntu-server-key') // Jenkins credential ID for EC2 SSH key
    }
    stages {
        stage("Build") {
            steps {
                // Clean and package the application using Maven
                sh './mvnw clean package'
            }
        }
        stage("Build Docker Image") {
            steps {
                script {
                    // Build the Docker image with a specified tag
                    sh "docker build -t ${IMAGE_NAME} ."
                }
            }
        }
        stage("Login to Docker Registry") {
            steps {
                script {
                    // Login to the private Docker registry securely
                    withCredentials([usernamePassword(credentialsId: 'docker-credentials-id', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh """
                        echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
                        """
                    }
                }
            }
        }
        stage("Push Docker Image") {
            steps {
                script {
                    // Push the Docker image with the specified tag to the repository
                    sh "docker push ${IMAGE_NAME}"
                }
            }
        }
        stage("Deploy to EC2") {
            steps {
                script {
                    // SSH into EC2 and deploy the Docker container securely
                    sshagent(['ubuntu-server-key']) {
                        sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} '
                        docker pull ${IMAGE_NAME} &&
                        docker run -d -p 9000:9000 --name your-container-name ${IMAGE_NAME}
                        '
                        """
                    }
                }
            }
        }
    }
    post {
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed!'
        }
    }
}