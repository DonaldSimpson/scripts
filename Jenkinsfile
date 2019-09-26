pipeline {
  agent {
    dockerfile {
      // build a custom image using the Dockerfle in this repo
      filename 'Dockerfile'
      // and mount the docker socket to it
      args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
  }
  options {
    disableConcurrentBuilds()
    parallelsAlwaysFailFast()
  }

  stages {

    // this stage uses the above image to run the following steps
    stage('Local build') {
      steps {
        script {
          sh "echo This container is `hostname`"
          // we've got access to the docker client (installed from tar.gz in the image build above)
          // and the docker daemon on the host via the mapped socket, so we can do this:
          sh 'docker inspect --format="{{.Config.Image}}" $HOSTNAME'
          // and verify the file "touched" during build is here:
          sh 'echo Listing files in /tmp:'
          sh 'ls -al /tmp'
        }
      }
    }

    stage('Back-end example') {
      // these stages are from the examples
      // https://jenkins.io/doc/book/pipeline/docker/
      // and pull the specified image from docker hub
      agent {
        docker { image 'maven:3-alpine' }
      }
      steps {
        sh "echo This container is `hostname`"
        // no docker client, can't inspect this
        // but we can verify that mvn works:
        sh 'mvn --version'
      }
    }

    stage('Front-end example') {
      agent {
        docker { image 'node:7-alpine' }
      }
      steps {
        sh "echo This container is `hostname`"
        // no docker client, can't inspect this
        // but we can verify that node works:
        sh 'node --version'
      }
    }
  }
}
