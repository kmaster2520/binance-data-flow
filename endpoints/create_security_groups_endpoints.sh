#!/bin/bash

VPC_ID="vpc-013914d1062557cd7"
SUBNET_ID="subnet-0ac0bc58b5403af7b"

aws cloudformation create-stack \
  --stack-name CoinbaseSecurityGroups \
  --template-body file://btc-websocket-endpoints.yaml \
  --parameters \
      ParameterKey=VpcId,ParameterValue=$VPC_ID \
      ParameterKey=SubnetId,ParameterValue=$SUBNET_ID
