#!/bin/bash
#Determine metadata
export AWS_REGION="$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')"
echo "AWS Region: [${AWS_REGION}]"
    
export AWS_EC2_ID="$(ec2-metadata -i | awk '{print $2}')"
echo "EC2 ID of runner: [${AWS_EC2_ID}]"

__cmdstr_envname="/usr/local/bin/aws ec2 describe-tags --region ${AWS_REGION} --filters \"Name=resource-id,Values=${AWS_EC2_ID}\" \"Name=key,Values=environment-name\" | jq -r '.Tags[0].Value'"
ENV_NAME="$(eval ${__cmdstr_envname})"
echo "Environment Name: [${ENV_NAME}]"
    
# Get WWW Launch Template ID
__cmdstr_www_lt_id="/usr/local/bin/aws ec2 describe-launch-templates --launch-template-names bat-lt-${ENV_NAME}-www | jq -r '.LaunchTemplates[0].DefaultVersionNumber'"
WWW_LT_ID1="$(eval ${__cmdstr_www_lt_id})"
echo "Launch Template Version: [${WWW_LT_ID1}]"
echo "Autoscale Group Name: [bat-asg-${BAT_ENV_NAME}-www]"

for i in `aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name bat-asg-${BAT_ENV_NAME}-www | grep -i instanceid  | awk '{ print $2}' | cut -d',' -f1| sed -e 's/"//g'`
do
PRIVATE_IP=$(aws ec2 describe-instances --instance-ids $i | grep -i PrivateIpAddress | awk '{ print $2 }' | head -1 | cut -d"," -f1 | tr -d '"')
echo "Instance [$i] has IP address [$PRIVATE_IP]"
done
