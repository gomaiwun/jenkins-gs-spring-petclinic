pipeline {
    agent any
    environment {
        EC2_USER = 'ec2-user' // Replace with your EC2 username
        EC2_HOST = '35.170.201.45' // Replace with your EC2 instance IP or hostname
        EC2_KEY = credentials('ec2-server-key') // Replace with your Jenkins credential ID
        REMOTE_PATH = '/home/ec2-user' // Path on EC2 where you want to deploy
    }
    stages {
        stage("build") {
            steps {
                sh "./mvnw clean package"
            }
        }
        stage("transfer JAR") {
            steps {
                script {
                    def jarFile = 'target/spring-petclinic-3.1.0-SNAPSHOT.jar'
                    sh """
                    scp -i ${EC2_KEY} -o StrictHostKeyChecking=no ${jarFile} ${EC2_USER}@${EC2_HOST}:${REMOTE_PATH}
                    """
                }
            }
        }
        stage("deploy") {
            steps {
                script {
                    // Connect to the EC2 instance and run the JAR file
                    sh """
                    ssh -i ${EC2_KEY} -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} 'java -jar ${REMOTE_PATH}/spring-petclinic-3.1.0-SNAPSHOT.jar'
                    """
                }
            }
        }
        stage("capture") {
            steps {
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