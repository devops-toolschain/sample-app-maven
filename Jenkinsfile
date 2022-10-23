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
                    sh 'mvn -version'
                    sh 'mvn clean package'

                    sh 'ls -al target'
                }
            }

            // stage('Code Quality') {
            //     dir('java-app') {
            //         withSonarQubeEnv(credentialsId: 'jenkins-sonar-token', installationName: 'sonarcloud') {
            //         sh 'mvn verify sonar:sonar -Dsonar.projectKey=sample-app-maven'
            //         }
            //     }
            // }

            stage('Deploy') {
                dir('java-app/target') {
                    sshagent(credentials: ['AZURE_VM_SSH_PRIVAT_KEY']) {
                        sh '
                            [ -d ~/.ssh ] || mkdir ~/.ssh && chmod 0700 ~/.ssh
                            ssh-keyscan -t rsa,dsa 20.77.96.60 >> ~/.ssh/known_hosts
                            scp hello-world-1.war
                        '
                    }

                    // withCredentials([
                    //     string(credentialsId: 'AZURE_VM_SSH_PRIVAT_KEY', variable: 'AZURE_VM_SSH_PRIVAT_KEY')
                    // ]) {
                    //     sshPublisher(
                    //         continueOnError: false, 
                    //         failOnError: true,
                    //         publishers: [
                    //             sshPublisherDesc(
                    //             configName: "$AZURE_VM_SSH_PRIVAT_KEY",
                    //             transfers: [sshTransfer(sourceFiles: 'hello-world-1.war')],
                    //             verbose: true
                    //         )]
                    //     )
                    // }
                }
            }
        }
    }
}