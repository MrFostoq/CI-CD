pipeline {
    agent { label 'Jenkins-agent' }
    
    tools {
        maven 'Maven3'
        jdk 'JDK17'
    }
    environment {
        APP_NAME = 'Test-app-pipeline'
        RELEASE = '1.0.0'
        DOCKER_USER = 'Fostoq'
        DOCKER_PASS = 'dockerhub'
        IMAGE_NAME = '${DOCKER_USER}' + '/' + '${APP_NAME}'
        IMAGE_TAG = '${RELEASE}-${BUILD_NUMBER}'
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
        stage('Sonar code Analysis') {
            steps {
                script {
                    withSonarQubeEnv('sonar-server'){
                        sh 'mvn sonar:sonar'
                    }
                }
            }
        }
        stage('Quality Gate') {
            steps {
                // Wait for the SonarQube Quality Gate result
                script {
                    timeout(time: 10, unit: 'MINUTES') { // Wait up to 10 minutes for the Quality Gate result
                        def qg = waitForQualityGate() // Check the Quality Gate status
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to Quality Gate failure: ${qg.status}"
                        }
                    }
                }
                echo 'Quality Gate passed!'
            }
        }
        stage('Docker Build & Push') {
            steps {
                script {
                    docker.withRegistry('', DOCKER_PASS) {
                        docker_image = docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                        image.push()
                    }
                }
            }
        }
    }
}
