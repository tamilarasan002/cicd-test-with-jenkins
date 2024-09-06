pipeline {
    agent any
    
    environment {
        // Define environment variables
        REGISTRY = "192.168.4.81:5000"
        IMAGE_NAME = "helloworld"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        KUBECONFIG = credentials('config') // Kubernetes credentials
    }
    
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Tamilarasand02/cicd-test-with-jenkins.git'
            }
        }
        
        stage('Build') {
            steps {
                script {
                    sh 'mvn clean package'
                }
            }
        }
        
        stage('Docker Build & Push') {
            steps {
                script {
                    docker.build("${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}")
                    docker.withRegistry("http://${REGISTRY}", 'dockerhub-credentials') {
                        docker.image("${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}").push("${IMAGE_TAG}")
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
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
    sh "kubectl apply -f ${file} --kubeconfig=${env.KUBECONFIG}"
}
