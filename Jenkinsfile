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
        
        stage('Build') {
            agent {
                docker {
                  reuseNode true 
                  docker 'maven:3.5-alpine'
                  args '-v /root/.m2:/root/.m2'
              }
            }
            steps {
                sh 'mvn clean package'
                junit '**/target/surefire-reports/TEST-*.xml'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
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
}
