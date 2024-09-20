pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['Docker', 'Kubernetes'], description: 'Select the action to perform')
        string(name: 'REGISTRY', defaultValue: '192.168.4.81:5000', description: 'Docker registry URL')
        string(name: 'IMAGE_NAME', defaultValue: 'helloworld', description: 'Name of the Docker image')
        string(name: 'IMAGE_TAG', defaultValue: "${env.BUILD_NUMBER}-${env.GIT_COMMIT.substring(0, 7)}", description: 'Tag for the Docker image')

        // Active Choice Parameter for Kubernetes
        activeChoice(name: 'KUBE_CONFIG', description: 'Kubernetes credentials ID', 
                     choices: ['81conf', 'another-credential'].collect { it },
                     filterable: true).when {
            expression { params.ACTION == 'Kubernetes' }
        }

        activeChoice(name: 'DEPLOYMENT_FILE', description: 'Kubernetes deployment file path', 
                     choices: ['deploy.yaml', 'another-file.yaml'].collect { it },
                     filterable: true).when {
            expression { params.ACTION == 'Kubernetes' }
        }
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
                expression { params.ACTION == 'Docker' }
            }
            steps {
                script {
                    // Build Docker image
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
                expression { params.ACTION == 'Kubernetes' }
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
                expression { params.ACTION == 'Kubernetes' }
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
