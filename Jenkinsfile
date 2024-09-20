pipeline {
    agent any
    
    environment {
        // Define environment variables
        REGISTRY = "192.168.4.81:5000"
        IMAGE_NAME = "helloworld"
        IMAGE_TAG = "v1"
        KUBECONFIG = credentials('81conf') // Kubernetes credentials
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Tamilarasand02/cicd-test-with-jenkins.git'
            }
        }
        
        stage('Build') {
            steps {
                script {
                    // Build the Maven project
                    sh 'mvn clean package'
                }
            }
        }
        
        stage('Docker Build & Push') {
            steps {
                script {
                    // Build Docker image
                    docker.build("${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}")
                    
                    // Push Docker image to private registry
                    docker.withRegistry("http://${REGISTRY}") {
                        docker.image("${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}").push("${IMAGE_TAG}")
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Deploy to Kubernetes using kubectl
                    sh "kubectl --kubeconfig=${KUBECONFIG} apply -f ${WORKSPACE}/deploy.yaml"
                }
            }
        }
    }
    
    post {
        success {
            echo "Build and deployment successful!"
        }
        failure {
            echo "Build or deployment failed."
        }
    }
}
