pipeline {
  agent {
      dockerfile {
        filename 'Dockerfile'
          args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
      }
      options {
        disableConcurrentBuilds()
        parallelsAlwaysFailFast()
      }
      stages {
        stage('Local build') {
          steps {
            script {
              sh 'echo Hi'
              sh 'printenv'
              sh 'ls -al /tmp'
            }
          }
        }
        stage('Back-end example') {
          agent {
            docker { image 'maven:3-alpine' }
          }
          steps {
            sh 'mvn --version'
          }
        }
        stage('Front-end example') {
          agent {
            docker { image 'node:7-alpine' }
          }
          steps {
            sh 'node --version'
          }
        }
      }
}
