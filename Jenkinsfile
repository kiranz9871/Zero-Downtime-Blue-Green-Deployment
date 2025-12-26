pipeline {
  agent any

  environment {
    APP_NAME = "flask-app"
    IMAGE_TAG = "${BUILD_NUMBER}"
    REGISTRY = "kiranz9871"
  }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/kiranz9871/Zero-Downtime-Blue-Green-Deployment.git'
      }
    }

    stage('Build Image') {
      steps {
        sh "docker build -t ${REGISTRY}/${APP_NAME}:${IMAGE_TAG} ."
      }
    }

    stage('Deploy Green') {
      steps {
        sh '''
        docker rm -f green || true
        docker run -d --name green --network bluegreen-net \
        -e APP_VERSION=${IMAGE_TAG} ${REGISTRY}/${APP_NAME}:${IMAGE_TAG}
        '''
      }
    }

    stage('Health Check') {
      steps {
        sh '''
        sleep 5
        curl -f http://green:8001/health
        '''
      }
    }

    stage('Switch Traffic') {
      steps {
        sh "./switch.sh"
      }
    }
  }

  post {
    failure {
      sh "./switch.sh"
      echo "Rolled back automatically"
    }
  }
}
