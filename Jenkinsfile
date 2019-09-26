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
          sh "echo This container is `hostname`"
          sh 'docker inspect --format="{{.Config.Image}}" $HOSTNAME'
          sh 'echo Listing files in /tmp:'
          sh 'ls -al /tmp'
        }
      }
    }
    stage('Back-end example') {
      agent {
        docker { image 'maven:3-alpine' }
      }
      steps {
        sh "echo This container is `hostname`"
        sh 'mvn --version'
      }
    }
    stage('Front-end example') {
      agent {
        docker { image 'node:7-alpine' }
      }
      steps {
        sh "echo This container is `hostname`"
        sh 'node --version'
      }
    }
  }
}
