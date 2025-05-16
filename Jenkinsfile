pipeline {
    agent { label 'Jenkins-agent' }
    
    tools {
        maven 'Maven3'
        jdk 'JDK17'
    }

    stages {
        stage('Cleanup workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout from SCM') {
            steps {
                git branch: 'main', credentialsId: 'githup', url: 'https://github.com/MrFostoq/CI-CD.git'
            }
        }

        stage('Build App') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Unit test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Check style analysis') {
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
        }
    }
}
