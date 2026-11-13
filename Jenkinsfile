
pipeline {
    agent any

    stages {
        stage('Checkout Terraform') {
            steps {
                checkout scm
                echo 'Terraform repository downloaded successfully'
            }
        }

        stage('Checkout Ansible') {
            steps {
                dir('ansible') {
                    git branch: 'main',
                        url: 'https://github.com/sambasd/Ansible-2026.git'
                }
                echo 'Ansible repository downloaded successfully'
            }
        }

        stage('Check Tools') {
            steps {
                sh '''
                    echo "Checking Terraform"
                    terraform version

                    echo "Checking Ansible"
                    /usr/local/bin/ansible --version

                    echo "Checking project files"
                    ls -la
                    ls -la ansible/
                '''
            }
        }
    }

    post {
        success {
            echo 'Both repositories and tools verified successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the Jenkins console output.'
        }
    }
}
