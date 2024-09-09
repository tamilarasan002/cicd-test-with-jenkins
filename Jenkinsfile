pipeline {
    agent any
    
    environment {
        // Define environment variables
        REGISTRY = "192.168.4.81:5000"
        IMAGE_NAME = "helloworld"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        KUBECONFIG = credentials('admin_conf') // Kubernetes credentials
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
                    // Dynamically set the IMAGE_TAG in the Build stage
                    IMAGE_TAG = "${env.BUILD_NUMBER}"
                    
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
                    docker.withRegistry("http://${REGISTRY}", 'dockerhub-credentials') {
                        docker.image("${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}").push("${IMAGE_TAG}")
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Deploy to Kubernetes using kubectl
                    kubectlApply("deploy.yaml")
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

def kubectlApply(file) {
    sh """
    set -e
    kubectl apply -f ${file} --kubeconfig=${env.KUBECONFIG}
    """
}
