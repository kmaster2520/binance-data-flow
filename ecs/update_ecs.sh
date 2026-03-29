#!/bin/bash

PRODUCT_IDS="BTC-USD,ETH-USD"
#PRODUCT_IDS="LTC-USD"

aws cloudformation deploy \
  --stack-name CoinbaseECSCluster \
  --template-file websocket_ecs_cft.yaml \
  --parameter-overrides \
      CoinbaseProductId="$PRODUCT_IDS" \
  --capabilities CAPABILITY_NAMED_IAM
