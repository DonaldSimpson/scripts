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
        stage('Prep steps') {
          steps {
            script {
              sh 'echo Hi'
              sh 'printenv'
              sh 'ls -al /tmp'
            }
          }
        }
        stage('Front-end') {
          agent {
            docker { image 'node:7-alpine' }
          }
          steps {
            sh 'node --version'
          }
        }
      }
}
