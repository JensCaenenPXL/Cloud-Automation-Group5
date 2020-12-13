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
        stage('Execute main.tf') {
            steps {
               echo 'Running main.tf'
                sh 'terraform init'
                sh 'terraform apply -auto-approve'
            }
        }
        stage('Execute module_one.tf') {
            steps {
               echo 'Running module_two.tf'
               dir('./module_one'){
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
               }
            }
        }
    } 
}
