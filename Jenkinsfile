pipeline {
  agent any
    stages{
        stage('Check Dependencies') {
            steps {
                echo 'Checking if dependencies are installed'
                sh 'terraform -version'
                sh 'packer -version'
            }
        }
        stage('Execute module_one.tf') {
            steps {
                echo 'Running module_one.tf'
                dir('module_one') {
                    sh 'terraform init'
                    sh 'terraform apply -input=false'
                }
            }
        }
        stage('Execute packer.json') {
            steps {
                echo 'Pushing the localhost.yml to GitHub'
                sh 'git commit -m "Updated localhost.yml" -a'
                sh 'git push'
                echo 'Running packer.json'
                sh 'packer build packer.json'
            }
        }
        stage('Execute module_two.tf') {
            steps {
                echo 'Running module_two.tf'
                dir('module_two') {
                    sh 'terraform init'
                    sh 'terraform apply -input=false'
                }
            }
        }
    } 
}
