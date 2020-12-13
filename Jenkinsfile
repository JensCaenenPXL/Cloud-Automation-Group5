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
        //stage('Destroy existing infrastructure') {
        //    steps {
        //        echo 'Destroying existing infrastructure'
        //        sh 'terraform init'
        //        sh 'terraform destroy -auto-approve'
        //    }
        //}
        stage('Execute Terraform') {
            steps {
               echo 'Running module_one.tf'
                sh 'terraform init'
                sh 'terraform apply -auto-approve'
            }
        }
    } 
}
