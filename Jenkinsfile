pipeline {
    agent any

    tools {
        terraform 'terraform'
    }

    // Parameters for manual builds
    parameters {
        choice(
            name: 'action',
            choices: ['apply', 'destroy'],
            description: 'Select the action to perform (only for manual builds)'
        )
    }

    triggers {
        // Poll SCM every minute for automatic builds
        pollSCM('* * * * *')
    }

    environment {
        SLACKCHANNEL = 'C0A94TNNGKC'               // Your Slack channel ID
        SLACKCREDENTIALS = credentials('slack-bot-token')  // Slack bot token stored in Jenkins
        PIPENV_BIN = "${HOME}/.local/bin/pipenv"   // Ensure pipenv is found

        // AWS Credentials stored in Jenkins (safe, not in GitHub)
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        AWS_DEFAULT_REGION    = 'eu-west-3'        // Change to your AWS region
    }

    stages {

        stage('IAC Scan') {
            steps {
                script {
                    // Install pipenv if missing
                    sh """
                    if ! command -v $PIPENV_BIN &> /dev/null; then
                        pip install --user pipenv
                    fi
                    """
                    sh "$PIPENV_BIN install checkov || true"
                    sh "$PIPENV_BIN run checkov -d . -o cli || true"
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
            when {
                expression {
                    // Only run Terraform apply/destroy if manually triggered
                    return currentBuild.rawBuild.getCause(hudson.model.Cause$UserIdCause) != null
                }
            }
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
