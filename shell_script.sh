#!/bin/bash

###############################################################################
# Author: Joel Chandanshiv
# Version: v0.0.3
#
# Script to automate AWS resource listing and email the daily report.
###############################################################################

# Set log file location
LOG_FILE="/home/ubuntu/aws_resource_report.log"
AWS_REGION=$(aws configure get region)

# Fallback if AWS_REGION is empty
if [ -z "$AWS_REGION" ]; then
    AWS_REGION="eu-north-1" # Default AWS Region (modify as needed)
fi

# Email Configuration
EMAIL_TO="joelchandanshiv91@gmail.com"
EMAIL_FROM="joelchandanshiv@gmail.com"
SUBJECT="Daily AWS Resource Report - $(date '+%Y-%m-%d')"

# Start logging
echo "AWS Resource Report - $(date)" > "$LOG_FILE"

# Function to list resources
list_resources() {
    SERVICE_NAME=$1
    AWS_COMMAND=$2

    echo "### $SERVICE_NAME ###" >> "$LOG_FILE"
    eval "$AWS_COMMAND" >> "$LOG_FILE" 2>&1
    echo -e "\n" >> "$LOG_FILE"
}

# List AWS Resources
list_resources "EC2 Instances" "aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,InstanceType]' --region $AWS_REGION --output table"
list_resources "RDS Instances" "aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceClass,DBInstanceStatus]' --region $AWS_REGION --output table"
list_resources "S3 Buckets" "aws s3api list-buckets --query 'Buckets[*].Name' --output table"
list_resources "CloudFront Distributions" "aws cloudfront list-distributions --output json"
list_resources "VPCs" "aws ec2 describe-vpcs --region $AWS_REGION --output table"
list_resources "IAM Users" "aws iam list-users --output table"
list_resources "Route53 Hosted Zones" "aws route53 list-hosted-zones --output json"
list_resources "CloudWatch Alarms" "aws cloudwatch describe-alarms --region $AWS_REGION --output table"
list_resources "CloudFormation Stacks" "aws cloudformation describe-stacks --region $AWS_REGION --output table"
list_resources "Lambda Functions" "aws lambda list-functions --region $AWS_REGION --output table"
list_resources "SNS Topics" "aws sns list-topics --region $AWS_REGION --output json"
list_resources "SQS Queues" "aws sqs list-queues --region $AWS_REGION --output json"
list_resources "DynamoDB Tables" "aws dynamodb list-tables --region $AWS_REGION --output json"
list_resources "EBS Volumes" "aws ec2 describe-volumes --region $AWS_REGION --output table"

# Send Email with Report (Using mailutils)
echo "Please find the attached AWS Resource Report." | mail -s "$SUBJECT" -A "$LOG_FILE" "$EMAIL_TO"

# Alternative: If `mail` doesn't work, use `mutt`
# echo "AWS Resource Report Attached" | mutt -s "$SUBJECT" -a "$LOG_FILE" -- "$EMAIL_TO"

exit 0

