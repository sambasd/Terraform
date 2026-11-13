pipeline {
    agent any

    options {
        disableConcurrentBuilds()
    }

    stages {

        stage('Checkout Terraform') {
            steps {
                checkout scm
            }
        }

        stage('Checkout Ansible') {
            steps {
                dir('ansible') {
                    git branch: 'main',
                        url: 'https://github.com/sambasd/Ansible-2026.git'
                }
            }
        }

        stage('Check Tools') {
            steps {
                sh '''
                    terraform version
                    /usr/local/bin/ansible --version
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform -chdir=/opt/terraform-projects/aws-50-rhel init -input=false'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform -chdir=/opt/terraform-projects/aws-50-rhel validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform -chdir=/opt/terraform-projects/aws-50-rhel plan -input=false -out=jenkins.tfplan'
            }
        }

        stage('Approve Deployment') {
            steps {
                input message: 'Approve creation of 2 RHEL EC2 servers?', ok: 'Deploy'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform -chdir=/opt/terraform-projects/aws-50-rhel apply -input=false jenkins.tfplan'
            }
        }

        stage('Terraform Output') {
            steps {
                sh 'terraform -chdir=/opt/terraform-projects/aws-50-rhel output'
            }
        }
    }
}
