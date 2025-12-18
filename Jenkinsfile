pipeline {
  agent any

  environment {
    APP_NAME = "sample-flask-app"
  }
stages {
  stage ('checkout') {
    steps {
    echo "checking the code"
    }
  }

  stage ('test') {
    steps {
    echo "testing the code"
    }
  }
  stage ('package') {
    steps {
    echo "building the package"
    }
  }

  stage ('build') {
    steps {
    echo "building the app"
    }
  }
  
  stage ('deploy') {
    steps {
    echo "deploying the app new version"
    }
  }
}
post {
    always {
      echo "i will say always hello again"
    }

    failure {
      echo "failure"
    }
  
    success {
      echo "success"
    }
  
  }
}
