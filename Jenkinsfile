pipeline {
  agent any
    stages{
        stage('Pull GitHub repository') {
            steps {
                git credentialsId: 'dac8b051-5e23-4284-8c6a-ac83849eeaf3', url: 'https://github.com/JensCaenenPXL/Cloud-Automation-Group5.git'
            }
        }
    } 
}
