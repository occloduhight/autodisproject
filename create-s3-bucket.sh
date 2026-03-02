#!/bin/bash
set -euo pipefail  # Enable strict error handling

# -----------------------------
# Set Variables
# -----------------------------
BUCKET_NAME="autodiscbucket"
AWS_REGION="us-east-1"
PROFILE="default"

# -----------------------------
# Function to handle errors
# -----------------------------
handle_error() {
    echo "❌ Error: $1"
    exit 1
}

# -----------------------------
# Create S3 Bucket
# -----------------------------
echo "🚀 Creating S3 bucket: $BUCKET_NAME..."
if aws s3api head-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" --profile "$PROFILE" 2>/dev/null; then
    echo "⚠️  Bucket '$BUCKET_NAME' already exists. Skipping creation."
else
    if [ "$AWS_REGION" = "us-east-1" ]; then
        # us-east-1 does not require LocationConstraint
        if ! aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION" --profile "$PROFILE"; then
            handle_error "Failed to create S3 bucket '$BUCKET_NAME'."
        fi
    else
        # All other regions require LocationConstraint
        if ! aws s3api create-bucket \
            --bucket "$BUCKET_NAME" \
            --region "$AWS_REGION" \
            --profile "$PROFILE" \
            --create-bucket-configuration LocationConstraint="$AWS_REGION"; then
            handle_error "Failed to create S3 bucket '$BUCKET_NAME'."
        fi
    fi
    echo "✅ S3 bucket '$BUCKET_NAME' created successfully."
fi

# -----------------------------
# Enable versioning
# -----------------------------
echo "🔄 Enabling versioning for S3 bucket..."
if ! aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled \
    --region "$AWS_REGION" \
    --profile "$PROFILE"; then
    handle_error "Failed to enable versioning for S3 bucket '$BUCKET_NAME'."
fi
echo "✅ Versioning enabled successfully."

# -----------------------------
# Provision Vault and Jenkins servers
# -----------------------------
echo "🚀 Provisioning Vault and Jenkins server..."
cd utility
terraform init
terraform fmt -recursive
terraform apply -auto-approve

echo "🎉 S3 Remote State Management Setup Complete!"
echo "🌍 S3 Bucket: $BUCKET_NAME"
