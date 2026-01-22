pipeline {
    agent any

    tools {
        terraform 'terraform'
    }

    parameters {
        choice(
            name: 'action',
            choices: ['apply', 'destroy'],
            description: 'Select Terraform action'
        )
    }

    triggers {
        pollSCM('* * * * *')
    }

    environment {
        // Slack
        SLACKCHANNEL = 'C0A94TNNGKC'

        // Terraform secrets (from Jenkins credentials)
        TF_VAR_nr_key       = credentials('nr-api-key')
        TF_VAR_nr_acc_id    = credentials('nr-account-id')
        TF_VAR_db_username  = credentials('db-username')
        TF_VAR_db_password  = credentials('db-password')
        TF_VAR_vault_token  = credentials('vault-token')

        // Non-secret Terraform variables
        TF_VAR_domain_name  = 'odochidevops.space'
        TF_VAR_s3_bucket_name = 'autodiscbucket'
        TF_VAR_region       = 'eu-west-3'
    }

    stages {

        stage('IAC Scan') {
            steps {
                script {
                    sh 'python3 -m pip install --user checkov || true'
                    sh '~/.local/bin/checkov -d . -o cli || true'
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
                sh "terraform ${params.action} -auto-approve"
            }
        }
    }

    post {
        success {
            // Use credential ID directly instead of env.SLACKCREDENTIALS
            slackSend(
                channel: env.SLACKCHANNEL,
                tokenCredentialId: 'slack-bot-token',
                color: 'good',
                message: "✅ *SUCCESS*: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' completed successfully.\n${env.BUILD_URL}"
            )
        }

        failure {
            slackSend(
                channel: env.SLACKCHANNEL,
                tokenCredentialId: 'slack-bot-token',
                color: 'danger',
                message: "❌ *FAILED*: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' failed.\nCheck logs: ${env.BUILD_URL}"
            )
        }
    }
}
