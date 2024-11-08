#!/usr/bin/env groovy

pipeline {
  agent any

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

    stage('Build Dockerfile') {
      steps {
        script {
          ws("workspace") {
            docker.build('omeglestr:latest')
          }
        }
      }
    }

    stage('Publish') {
      steps {
        script {
          ws("workspace") {
            docker.withRegistry('https://ra9.local:5000', 'ra9-registry-credentials') {
              docker.image('omeglestr:latest').push()
            }
          }
        }
      }
    }
  }
}