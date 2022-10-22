podTemplate(containers: [
    containerTemplate(
        name: 'jnlp',
        image: 'devops-jenkins-agent:1.0'
        )
  ]) {

    node(POD_LABEL) {
        container('jnlp') {
    
            stage('Checkout') {
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/master']],
                    userRemoteConfigs: [[credentialsId: 'jenkins-credentials',
                    url: 'https://github.com/devops-toolschain/sample-app-maven.git']]])
            }
            
            stage('Print Variables') {
                sh 'echo Workspace is $WORKSPACE'
            }

            stage('Build') {
                dir('java-app') {
                    mvn clean package
                }
            }

            stage('Code Quality') {
                withSonarQubeEnv(credentialsId: 'jenkins-sonar-token', installationName: 'sonarcloud') {
                   sh 'mvn verify sonar:sonar -Dsonar.projectKey=sample-app-maven'
                }
            }

            stage('Build Infra') {
                withCredentials([
                    string(credentialsId: 'ARM_ACCESS_KEY', variable: 'ARM_ACCESS_KEY'), 
                    string(credentialsId: 'ARM_CLIENT_ID', variable: 'ARM_CLIENT_ID'),
                    string(credentialsId: 'ARM_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'),
                    string(credentialsId: 'ARM_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID'),
                    string(credentialsId: 'ARM_TENANT_ID', variable: 'ARM_TENANT_ID')
                ]) {
                    
                    dir('infrastructure') {
                        sh 'terraform version'
                    
                        sh 'terraform init -reconfigure -no-color \
                            -backend-config "resource_group_name=$TF_RESOURCEGROUP" \
                            -backend-config "storage_account_name=$TF_STORAGEACCOUNT" \
                            -backend-config "container_name=$TF_CONTAINERNAME" \
                            -backend-config "key=$JOB_BASE_NAME/prod/terraform.tfstate"'
    
                        sh 'terraform plan -no-color -out=tfplan -var env=prod -var-file=prod.tfvars'

                        sh 'terraform apply -no-color -auto-approve tfplan'
                    }
                }
            }
        }
    }
}