pipeline {
		agent any
    environment {
        CI = 'true'
    }
    stages {
		stage('Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'React-Code', url: 'https://github.com/zubairzb/react-build.git']]])
			}
        }
        stage('Build') {
            steps {
                sh 'zip -r frontend.zip . '
            }
        }
        stage('Artifact Upload') {
            steps {
                nexusArtifactUploader artifacts: [[artifactId: 'frontend', classifier: '', file: '/var/lib/jenkins/workspace/souq-frontend/frontend.zip', type: 'zip']], credentialsId: 'nexus', groupId: 'node', nexusUrl: '13.126.130.89:8081/nexus', nexusVersion: 'nexus2', protocol: 'http', repository: 'EcommerceFT', version: '1.0.3'
            }
        }
        stage('Deploy') {
            steps {
                sshagent(['13.233.164.188']) {
                sh """ssh -v ubuntu@13.233.164.188 << EOF
                cd /home/ubuntu/website/
                wget http://13.126.130.89:8081/nexus/content/repositories/EcommerceFT/node/frontend/1.0.3/frontend-1.0.3.zip 
                unzip frontend-1.0.3.zip
                rm -f frontend-1.0.3.zip
                docker build -t myweb .
                docker service rm web
                docker service create --name web --replicas 2 -d -p 80:80 myweb
                exit
                EOF"""
                }
            }
        }
    }
}
