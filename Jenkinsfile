pipeline {
    agent { label 'Jenkins-agent' }

    tools {
        maven 'Maven3'
        jdk 'JDK17'
    }

    environment {
        APP_NAME = 'reg-app'
        RELEASE = '1.0.0'
        DOCKER_USER = 'fostoq'
        DOCKERHUB_CREDENTIALS_ID = 'dockerhub'
        JENKINS_API_TOKEN = credentials("JENKINS_API_TOKEN")
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
            steps{
                sh 'mvn install -DskipTests'
            }
            post {
                success {
                    echo "Archiving artifact"
                    archiveArtifacts artifacts: '**/*.war' 
                }
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
                    withSonarQubeEnv('sonar-server') {
                        sh 'mvn sonar:sonar'
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    timeout(time: 10, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
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
                    def imageName = "${DOCKER_USER}/${APP_NAME}"
                    def env.IMAGE_TAG = "${RELEASE}-${env.BUILD_NUMBER}"

                    sh 'find . -name "*.war"'

                    docker.withRegistry('', "${DOCKERHUB_CREDENTIALS_ID}") {
                        def image = docker.build("${imageName}:${IMAGE_TAG}")
                        image.push()
                    }
                }
            }
        }
        stage("Trivy Scan") {
            steps {
                script {
                    def imageName = "${DOCKER_USER}/${APP_NAME}"
                    def env.IMAGE_TAG = "${RELEASE}-${env.BUILD_NUMBER}"
                    def fullImage = "${imageName}:${IMAGE_TAG}"

                    sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image ${fullImage} --no-progress --scanners vuln --exit-code 1 --severity HIGH,CRITICAL --format table"
                }
            }
        }


        stage ('Cleanup Artifacts') {
            steps {
                script {
                    def imageName = "${DOCKER_USER}/${APP_NAME}"
                    def imageTag = "${RELEASE}-${env.BUILD_NUMBER}"

                    sh "docker rmi ${imageName}:${imageTag} || true"
                }
            }
        }

        stage("Trigger CD Pipeline") {
            steps {
                script {
                    sh "curl -v -k --user Abd-Alrahman:${JENKINS_API_TOKEN} -X POST -H 'cache-control: no-cache' -H 'content-type: application/x-www-form-urlencoded' --data 'IMAGE_TAG=${IMAGE_TAG}' 'ec2-3-88-11-123.compute-1.amazonaws.com:8080/job/gitops-reg-app-cd/buildWithParameters?token=gitops-token'"
                }
            }
        }
    }
}