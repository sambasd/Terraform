
pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timestamps()
    }

    environment {
        TF_DIR = "${WORKSPACE}"
    }

    stages {

        stage('Checkout Terraform') {
            steps {
                checkout scm
            }
        }

        stage('Check Tools and AWS Identity') {
            steps {
                sh '''
                    set -e
                    terraform version
                    aws --version
                    aws sts get-caller-identity
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform -chdir="$TF_DIR" init'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform -chdir="$TF_DIR" validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                    set -e
                    terraform -chdir="$TF_DIR" plan \
                        -out="$TF_DIR/jenkins.tfplan"
                '''
            }
        }

        stage('Approve Terraform Apply') {
            steps {
                input message: 'Review the Terraform plan. Approve infrastructure changes?',
                      ok: 'Approve and Apply'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh '''
                    set -e
                    terraform -chdir="$TF_DIR" apply \
                        -auto-approve "$TF_DIR/jenkins.tfplan"
                '''
            }
        }

        stage('Terraform Output') {
            steps {
                sh 'terraform -chdir="$TF_DIR" output'
            }
        }
    }

    post {
        success {
            echo 'Terraform pipeline completed successfully.'
        }

        failure {
            echo 'Terraform failed. Review Console Output.'
        }
    }
}

