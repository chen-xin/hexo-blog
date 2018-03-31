pipeline {
  agent none
  stages {
    stage('Setup') {
      agent {
        docker {
          image 'node:8-alpine'
        }
      }
      steps {
        sh 'npm config set registry https://registry.npm.taobao.org/'
        // sh 'npm install'
        // sh 'npm run build'
        sh 'npm run testbuild'
      }
      post {
        success {
          sh 'ls -alR public'
          archiveArtifacts 'public/**/*'
        }
      }
    }
  }
}
