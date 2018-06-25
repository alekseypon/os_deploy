#!/bin/bash

sudo yum -y install awscli

# Get spot instance request tags to tags.json file
AWS_ACCESS_KEY_ID=$1 AWS_SECRET_ACCESS_KEY=$2 aws --region $3 ec2 describe-spot-instance-requests --spot-instance-request-ids $4 --query 'SpotInstanceRequests[0].Tags' > tags.json

# Set instance tags from tags.json file
AWS_ACCESS_KEY_ID=$1 AWS_SECRET_ACCESS_KEY=$2 aws --region $3 ec2 create-tags --resources $5 --tags file://tags.json && rm -rf tags.json
