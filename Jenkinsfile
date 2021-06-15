#!groovy

def providerID = 'terraform-provider-k8sraw'
def providerVersion = 'v0.2.1-tivo'

pipeline {
    agent none

    options {
        timeout( time: 1, unit: 'HOURS' )
        buildDiscarder( logRotator(daysToKeepStr: '15', numToKeepStr: '10') )
    }

    stages {
        stage('Build Application') {
            agent {
                dockerfile {
                    filename 'Dockerfile.tivo-build'
                    label 'docker'
                }
            }
            steps {
                sh "make build"
                sh "./build-multi-arch.sh ${providerID}_${providerVersion} ."
            }
        }

        stage( 'Publish to Provider Registry' ) {
            when { branch 'tivo-build' }

            agent {
                docker {
                    image "${TERRAFORM_REGISTRY_PUBLISHING_IMAGE}"
                    label 'docker'
                }
            }

            options { skipDefaultCheckout() }

            steps {
                withCredentials([usernamePassword(credentialsId: 'iam-terraform-provider-registry', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh "release.sh ${WORKSPACE} nabancard k8sraw"
                }
            }
        }
    }

    post {
        success {
            echo "Yay SUCCESS ..."
            script {
                def msg = "${currentBuild.result}: `${env.JOB_NAME}` #${env.BUILD_NUMBER}:\n${env.BUILD_URL}"
                slackSend(channel: "#terraform-providers", color: 'good', message: msg)
            }
        }

        failure {
            echo "Boo FAILURE ..."
            script {
                def msg = "${currentBuild.result}: `${env.JOB_NAME}` #${env.BUILD_NUMBER}:\n${env.BUILD_URL}"
                slackSend(channel: "#terraform-providers", color: 'danger', message: msg)
            }
        }
    }
}
