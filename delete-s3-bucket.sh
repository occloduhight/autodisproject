#!/bin/bash
set -euo pipefail  # Enable strict error handling

# Set Variables
BUCKET_NAME="autodiscbucket2"
AWS_REGION="us-east-1"
AWS_PROFILE="default"
TFVARS_FILE="terraform.auto.tfvars"

# Function to handle errors
handle_error() {
    echo "❌ Error: $1"
    exit 1
}

cd utility || handle_error "Cannot change to utility directory"

echo "Initializing Terraform backend..."
terraform init -reconfigure || handle_error "Terraform init failed"

echo "Destroying utility infrastructure with terraform.auto.tfvars..."
terraform destroy -var-file="$TFVARS_FILE" -auto-approve || handle_error "Terraform destroy failed"

echo "✅ Terraform destroy completed successfully. Proceeding to S3 cleanup."
cd ..

# List and delete all object versions in the bucket
VERSIONS=$(aws s3api list-object-versions \
    --bucket $BUCKET_NAME \
    --profile $AWS_PROFILE \
    --region $AWS_REGION \
    --output json)

# Delete all objects and their versions
echo "$VERSIONS" | jq -c '.Versions[]' | while read -r version; do
    KEY=$(echo "$version" | jq -r '.Key')
    VERSION_ID=$(echo "$version" | jq -r '.VersionId') 
    aws s3api delete-object \
        --bucket "$BUCKET_NAME" \
        --key "$KEY" \
        --version-id "$VERSION_ID" \
        --profile "$AWS_PROFILE" \
        --region "$AWS_REGION"
done

echo "$VERSIONS" | jq -c '.DeleteMarkers[]' | while read -r marker; do
    KEY=$(echo "$marker" | jq -r '.Key')
    VERSION_ID=$(echo "$marker" | jq -r '.VersionId') 
    aws s3api delete-object \
        --bucket "$BUCKET_NAME" \
        --key "$KEY" \
        --version-id "$VERSION_ID" \
        --profile "$AWS_PROFILE" \
        --region "$AWS_REGION"
done    

# Delete the S3 bucket
aws s3api delete-bucket \
    --bucket "$BUCKET_NAME" \
    --profile "$AWS_PROFILE" \
    --region "$AWS_REGION"   
echo "Bucket $BUCKET_NAME and all its contents have been deleted."


#!/bin/bash
# set -euo pipefail  # Enable strict error handling

# # Set Variables


# BUCKET_NAME="autodiscbucket2"
# AWS_REGION="us-east-1"
# AWS_PROFILE="default"

# # Function to handle errors
# handle_error() {
#     echo "❌ Error: $1"
#     exit 1
# }

# cd utility
# echo "Destroying utility infrastructure..."
# terraform destroy -auto-approve
# TF_EXIT_CODE=$?
# if [ "$TF_EXIT_CODE" -ne 0 ]; then
#     echo "❌ Terraform destroy failed with exit code $TF_EXIT_CODE. Aborting S3 bucket deletion."
#     exit $TF_EXIT_CODE
# fi

# echo "✅ Terraform destroy completed successfully. Proceeding to S3 cleanup."
# cd ..

# # List and delete all object versions in the bucket
# VERSIONS=$(aws s3api list-object-versions \
#     --bucket $BUCKET_NAME \
#     --profile $AWS_PROFILE \
#     --region $AWS_REGION \
#     --output json)

# # Delete all objects and their versions
# echo "$VERSIONS" | jq -c '.Versions[]' | while read -r version; do
#     KEY=$(echo "$version" | jq -r '.Key')
#     VERSION_ID=$(echo "$version" | jq -r '.VersionId') 
#     aws s3api delete-object \
#         --bucket $BUCKET_NAME \
#         --key "$KEY" \
#         --version-id "$VERSION_ID" \
#         --profile $AWS_PROFILE \
#         --region $AWS_REGION
# done
# echo "$VERSIONS" | jq -c '.DeleteMarkers[]' | while read -r marker; do
#     KEY=$(echo "$marker" | jq -r '.Key')
#     VERSION_ID=$(echo "$marker" | jq -r '.VersionId') 
#     aws s3api delete-object \
#         --bucket $BUCKET_NAME \
#         --key "$KEY" \
#         --version-id "$VERSION_ID" \
#         --profile $AWS_PROFILE \
#         --region $AWS_REGION
# done    

# # Delete the S3 bucket
# aws s3api delete-bucket \
#     --bucket $BUCKET_NAME \
#     --profile $AWS_PROFILE \
#     --region $AWS_REGION   
# echo "Bucket $BUCKET_NAME and all its contents have been deleted."