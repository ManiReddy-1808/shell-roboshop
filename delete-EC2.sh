#!/bin/bash

SG_ID="sg-04303efbdaed5c6f9"

instance=("mongodb" "catalogue" "redis" "user" "cart" "mysql" "shipping"  "rabbitmq" "payment" "frontend")

for name in ${instance[@]}
do
    echo "Searching instance with Name tag: $name"

    INSTANCE_IDS=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=$name" \
                  "Name=instance.group-id,Values=$SG_ID" \
                  "Name=instance-state-name,Values=running,stopped" \
        --query "Reservations[].Instances[].InstanceId" \
        --output text)

    if [ -z "$INSTANCE_IDS" ]; then
        echo "No instance found for $name"
    else
        echo "Terminating instances: $INSTANCE_IDS"
        aws ec2 terminate-instances \
            --instance-ids $INSTANCE_IDS \
            --skip-os-shutdown
    fi

    echo "-----------------------------------"
    echo ""
done
echo "All specified instances have been deleted."