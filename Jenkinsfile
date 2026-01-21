pipeline {
    agent any

    tools {
        terraform 'terraform'
    }

    parameters {
        choice(
            name: 'action',
            choices: ['apply', 'destroy'],
            description: 'Select the action to perform'
        )
    }

    triggers {
        pollSCM('* * * * *') // Runs every minute
    }

    environment {
        SLACKCHANNEL = 'C0A94TNNGKC'                        // Slack channel ID
        SLACKCREDENTIALS = credentials('slack-bot-token')   // Slack bot token credential in Jenkins
        PIPENV_BIN = "${env.HOME}/.local/bin/pipenv"        // Ensures Jenkins finds pipenv
           
    }

    stages {

        stage('IAC Scan') {
            steps {
                script {
                    // Install pipenv if not available
                    sh "${env.PIPENV_BIN} --version || python3 -m pip install --user pipenv"
                    // Install checkov dependencies
                    sh "${env.PIPENV_BIN} install checkov || true"
                    // Run checkov scan
                    sh "${env.PIPENV_BIN} run checkov -d . -o cli || true"
                }
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Format') {
            steps {
                sh 'terraform fmt --recursive'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Terraform Action') {
            steps {
                script {
                    sh "terraform ${params.action} -auto-approve"
                }
            }
        }
    }

    post {
        always {
            slackSend(
                channel: env.SLACKCHANNEL,
                tokenCredentialId: env.SLACKCREDENTIALS,
                color: currentBuild.currentResult == 'SUCCESS' ? 'good' : 'danger',
                message: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' finished: ${env.BUILD_URL}"
            )
        }
        failure {
            slackSend(
                channel: env.SLACKCHANNEL,
                tokenCredentialId: env.SLACKCREDENTIALS,
                color: 'danger',
                message: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' has failed. Check console output at ${env.BUILD_URL}."
            )
        }
        success {
            slackSend(
                channel: env.SLACKCHANNEL,
                tokenCredentialId: env.SLACKCREDENTIALS,
                color: 'good',
                message: "Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' completed successfully. Check console output at ${env.BUILD_URL}."
            )
        }
    }
}
