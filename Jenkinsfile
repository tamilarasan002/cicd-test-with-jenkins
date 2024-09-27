pipeline {
    agent any

    environment {
        // Define environment variables
        REGISTRY = "192.168.4.81:5000"
        IMAGE_NAME = "helloworld"
        IMAGE_TAG = "v1"
        KUBECONFIG = credentials('kubeconfig') // Kubernetes credentials
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
            when {
                expression { params.ACTION == 'Docker' || params.ACTION == 'Both' }
            }
            steps {
                script {
                    // Build Docker image with provided tag
                    docker.build("${params.REGISTRY}/${params.IMAGE_NAME}:${params.IMAGE_TAG}")

                    // Push Docker image to private registry
                    docker.withRegistry("http://${params.REGISTRY}") {
                        docker.image("${params.REGISTRY}/${params.IMAGE_NAME}:${params.IMAGE_TAG}").push()
                    }
                }
            }
        }

        stage('Update Kubernetes Manifests') {
            when {
                expression { params.ACTION == 'Kubernetes' || params.ACTION == 'Both' }
            }
            steps {
                script {
                    // Update the image tag in Kubernetes deployment YAML
                    sh """
                    sed -i 's|image: .*|image: ${params.REGISTRY}/${params.IMAGE_NAME}:${params.IMAGE_TAG}|g' $WORKSPACE/${params.DEPLOYMENT_FILE}
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            when {
                expression { params.ACTION == 'Kubernetes' || params.ACTION == 'Both' }
            }
            steps {
                script {
                    // Apply the updated YAML file to deploy the new image version
                    sh "kubectl --kubeconfig=${params.KUBE_CONFIG} apply -f $WORKSPACE/${params.DEPLOYMENT_FILE}"
                }
            }
        }
    }

    post {
        success {
            echo "Build and deployment successful with image tag: ${params.IMAGE_TAG}"
        }
        failure {
            echo "Build or deployment failed."
        }
    }
}
