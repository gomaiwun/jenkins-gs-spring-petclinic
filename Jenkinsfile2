pipeline {
    agent any
    environment {
        EC2_USER = 'ubuntu' // Replace with your EC2 username
        EC2_HOST = '3.83.218.178' // Replace with your EC2 instance IP or hostname
        REMOTE_PATH = '/home/ubuntu' // Path on EC2 where you want to deploy
    }
    stages {
        stage("build") {
            steps {
                // Build the application
                sh "./mvnw clean package"
            }
        }
        stage("transfer JAR") {
            steps {
                script {
                    def jarFile = 'target/spring-petclinic-3.1.0-SNAPSHOT.jar'
                    // Securely transfer the JAR file to EC2 instance using SSH agent
                    sshagent(['ubuntu-server-key']) { // Replace with your Jenkins credential ID
                        sh """
                        scp -o StrictHostKeyChecking=no ${jarFile} ${EC2_USER}@${EC2_HOST}:${REMOTE_PATH}
                        """
                    }
                }
            }
        }
        stage("deploy") {
            steps {
                script {
                    // Run the JAR file on the EC2 instance securely via SSH agent
                    sshagent(['ubuntu-server-key']) { // Replace with your Jenkins credential ID
                        sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} 'java -Dserver.port=9000 -jar ${REMOTE_PATH}/spring-petclinic-3.1.0-SNAPSHOT.jar > /dev/null 2>&1 &'
                        """
                    }
                }
            }
        }
        stage("capture") {
            steps {
                // Capture artifacts
                archiveArtifacts '**/target/*.jar'
                jacoco()
                junit '**/target/surefire-reports/TEST*.xml'
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