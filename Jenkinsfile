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
        stage('Execute module_one.tf') {
            steps {
               echo 'Running module_one.tf'
                sh 'terraform init'
                sh 'terraform apply -auto-approve'
            }
        }
        stage('Execute module_two.tf') {
            steps {
               echo 'Running module_two.tf'
                sh 'terraform init'
                sh 'terraform apply -auto-approve'
            }
        }
    } 
}
