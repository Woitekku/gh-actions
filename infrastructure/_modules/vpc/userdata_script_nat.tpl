#!/bin/bash

yum install -y jq

ACCOUNTNAME="${ACCOUNTNAME}"
ENVIRONMENT="${ENVIRONMENT}"
TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCEMAC=$(curl -sH "X-aws-ec2-metadata-token: $${TOKEN}" http://169.254.169.254/latest/meta-data/network/interfaces/macs/)
VPCID=$(curl -sH "X-aws-ec2-metadata-token: $${TOKEN}" http://169.254.169.254/latest/meta-data/network/interfaces/macs/$${INSTANCEMAC}/vpc-id)
AZID=$(curl -sH "X-aws-ec2-metadata-token: $${TOKEN}" http://169.254.169.254/latest/meta-data/placement/availability-zone-id)
INSTANCEID=$(curl -sH "X-aws-ec2-metadata-token: $${TOKEN}" http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -sH "X-aws-ec2-metadata-token: $${TOKEN}" http://169.254.169.254/latest/dynamic/instance-identity/document | jq .region -r)
APPSUBNETID=$(aws ec2 describe-subnets --region $${REGION} --filters "Name=vpc-id,Values=$${VPCID}" "Name=tag:Name,Values=$${ACCOUNTNAME}-$${ENVIRONMENT}-app-$${AZID}" --query "Subnets[0].SubnetId" --output text)
RTB=$(aws ec2 describe-route-tables --region $${REGION} --filters "Name=association.subnet-id,Values=$${APPSUBNETID}" --query "RouteTables[0].RouteTableId" --output text)
ENI=$(aws ec2 describe-network-interfaces --region $${REGION} --query 'NetworkInterfaces[*].{ENI:NetworkInterfaceId}' --filters Name=attachment.instance-id,Values=$${INSTANCEID} --output text)
EIP=$(aws ec2 describe-addresses --region $${REGION} --filters "Name=tag:Name,Values=$${ACCOUNTNAME}-$${ENVIRONMENT}-nat-$${AZID}" --query "Addresses[?AssociationId==null].PublicIp" --output text)

aws ec2 associate-address --instance-id $${INSTANCEID} --public-ip $${EIP} --region $${REGION}
aws ec2 replace-route --route-table-id $${RTB} --destination-cidr-block 0.0.0.0/0 --network-interface-id $${ENI} --region $${REGION}
RESULT=$?
if [ $${RESULT} -ne 0 ]; then
    aws ec2 create-route --route-table-id $${RTB} --destination-cidr-block 0.0.0.0/0 --network-interface-id $${ENI} --region $${REGION}
fi

aws ec2 modify-instance-attribute --no-source-dest-check --instance-id $${INSTANCEID} --region $${REGION}
sysctl -w net.ipv4.ip_forward=1
/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
yum install -y iptables-services
service iptables save


