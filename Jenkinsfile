pipeline {
    agent any
    
    stages {
        stage("checkout"){
            steps {
               sh "ls"
                git branch:'main', url: 'https://github.com/gomaiwun/jenkins-gs-spring-petclinic.git'
                sh "ls"
                sh "pwd"
                sh "whoami" 
            }
         }
        stage("build"){
            steps {
                sh "./mvnw package"
            }
            
        }
        stage("capture"){
            steps {
                 archiveArtifacts '**/target/*.jar'
                jacoco()
                junit'**/target/surefire-reports/TEST*.xml'
            }
        }
    }
    post {
        always {
            sh "echo Hello"
        }
    }
}