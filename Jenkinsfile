pipeline {
    
    agent { 
      label 'docker-agent' 
    }

    triggers {
        pollSCM('* * * * *')
    }

    environment {
        shortCommit = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
        TAG = "${env.BUILD_NUMBER}_${shortCommit}"
    }

    stages {


        stage('Compile') {
            agent {
                docker {
                    reuseNode true
                    image 'maven:3.5-alpine'
                    args '-v /root/.m2:/root/.m2'
                }
            }
            steps{
                sh "mvn -B -DskipTests clean compile"
            }
        }

        stage('Unit test') {
          
            agent {
                docker {
                  reuseNode true 
                  image 'maven:3.5-alpine'
                  args '-v /root/.m2:/root/.m2'
              }
            }
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                    //junit '**/target/surefire-reports/TEST-*.xml'
                }
            }
        }

        stage('SonarQube analysis') {
            agent {
                docker {
                    reuseNode true
                    image "maven:3.5-alpine"
                    args "-v /root/.m2:/root/.m2 --network jenkins_default"
                }
            }
            steps {
                withSonarQubeEnv('SonarQube') { 
                    sh "mvn sonar:sonar " +
                    "-Dsonar.projectKey=maven:spring-petclinic " +
                    "-Dsonar.projectName='Maven :: Spring Petclinic Project' " +
                    "-Dsonar.projectVersion=${env.TAG} " +
                    "-Dsonar.language=java " +
                    "-Dsonar.sources=src/main/ " +
                    "-Dsonar.tests=src/test/ " +
                    "-Dsonar.junit.reportPaths=target/surefire-reports/"
                }
            }
        }

        stage('Package') {
            agent {
                docker {
                  reuseNode true 
                  image 'maven:3.5-alpine'
                  args '-v /root/.m2:/root/.m2'
              }
            }
            steps {
                //sh 'mvn clean package'
                sh 'mvn -B -DskipTests package'
                //junit '**/target/surefire-reports/TEST-*.xml'
                //archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage("Docker build") {
            steps {
                sh "docker build -t prasantk/spring-petclinic:${env.TAG} ."
            }
        }

        stage("Docker login") {
            steps {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'dockerhub',
                                usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                    sh "docker login --username $USERNAME --password $PASSWORD"
                }
            }
        }

        stage("Docker push") {
            steps {
                sh "docker push prasantk/spring-petclinic:${env.TAG}"
            }
        }

        stage("Deploy to staging") {
            steps {
                input 'Do you approve the deployment?'
                sh "URL=staging.petclinic.local docker-compose -p staging up -d"
            }
        }

        // stage('Deploy') {
        //   steps {
        //     input 'Do you approve the deployment?'
        //     sh 'scp target/*.jar jenkins@192.168.50.10:/opt/pet/'
        //     sh "ssh jenkins@192.168.50.10 'nohup java -jar /opt/pet/spring-petclinic-1.5.1.jar &'"
        //   }
        // }

    }

    post {
        success {
            slackSend (color: '#00FF00', message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
        }

        failure {
            slackSend (color: '#FF0000', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")           
        }
    }
}
