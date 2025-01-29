pipeline {
    agent any
    parameters {
        string(name: 'VERSION', defaultValue: '1.0.0', description: 'Enter the version for the Docker image.')
        string(name: 'EC2_HOST', defaultValue: '34.205.72.138', description: 'Enter the EC2 instance IP or hostname.') // EC2_HOST parameter
        string(name: 'IMAGE_NAME', defaultValue: 'gomaiwun/demo-application', description: 'Enter the Docker image name (without tag).') // Added IMAGE_NAME parameter
        string(name: 'EC2_USER', defaultValue: 'ubuntu', description: 'Enter the EC2 username.') // Added EC2_USER parameter
        string(name: 'CONTAINER_NAME', defaultValue: 'your-container-name', description: 'Enter the name for the Docker container.') // Added CONTAINER_NAME parameter
    }
    environment {
        // Project parameters - replace with your actual values
        FULL_IMAGE_NAME = "${params.IMAGE_NAME}:${params.VERSION}" // Full Docker image name with tag
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
                    sh "docker build -t ${FULL_IMAGE_NAME} ."
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
                    sh "docker push ${FULL_IMAGE_NAME}"
                }
            }
        }
        stage("Deploy to EC2") {
            steps {
                script {
                    // SSH into EC2 and deploy using Docker Compose
                    sshagent(['ubuntu-server-key']) {
                        sh """
                        scp -o StrictHostKeyChecking=no -i ${EC2_KEY} docker-compose.yml ${EC2_USER}@${EC2_HOST}:${REMOTE_PATH}
                        ssh -o StrictHostKeyChecking=no -i ${EC2_KEY} ${EC2_USER}@${EC2_HOST} '
                          cd ${REMOTE_PATH} &&
                          docker-compose -f docker-compose.yml up -d
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