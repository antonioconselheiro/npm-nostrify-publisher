#!/usr/bin/env groovy

pipeline {
  agent any

  tools {
    nodejs 'NpxNodeJS'
  }

  stages {
    stage('Clean Workspace') {
      steps {
        script {
          ws("workspace") {
            cleanWs()
          }
        }
      }
    }

    stage('Checkout') {
      steps {
        script {
          ws("workspace") {
            git branch: 'master',
            url: 'https://gitlab.com/soapbox-pub/nostrify.git'
          }
        }
      }
    }
  }
}