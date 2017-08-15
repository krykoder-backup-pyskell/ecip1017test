#!/bin/bash

set -e

echo "-------------------------------------------------------"
echo "NODE  : $NODE_ID"
echo "PEERS : $NODE_PEERS"
echo "-------------------------------------------------------"

OPTS=""

python ids.py node-id $NODE_ID > nodekey.txt

touch bootnodes.txt
while IFS=',' read -ra PEERS; do
    for name in ${PEERS[@]}; do
      PEER_ID=$(python ids.py node-id $name)
      PEER_HOST="$name"
      PEER_IP=$(host $PEER_HOST | awk '/has address/ { print $4 ; exit }')
      echo "enode://$PEER_ID@$PEER_IP:30303" >> bootnodes.txt
    done
done <<<  "$NODE_PEERS"

BOOTNODES=$(cat bootnodes.txt)
echo "PEERS:"
echo $BOOTNODES

jq -n --arg v "$BOOTNODES" '{"bootstrap": $v | split("\n")}' > bootnodes.json
jq -s '.[0] * .[1]' ecip1017chain.json bootnodes.json > chain.json

#BOOT=$(tr '\n' ',' < bootnodes.txt | sed -e 's/,$/\n/')

mkdir -p /data/ecip1017
cp ./chain.json /data/ecip1017/chain.json

NODEADDR=$(python ids.py addr $NODE_ID)

OPTS="$OPTS --datadir /data"
OPTS="$OPTS --rpc --rpcaddr 0.0.0.0"
OPTS="$OPTS --chain ecip1017"
#OPTS="$OPTS --bootnodes $BOOT --no-discover"
OPTS="$OPTS --no-discover"
OPTS="$OPTS --nodekey nodekey.txt"
OPTS="$OPTS --etherbase $NODEADDR"


#OPTS="$OPTS"

echo "-------------------------------------------------------"
echo "Run Geth:"
echo "    $OPTS"
echo "-------------------------------------------------------"


/go/bin/geth $OPTS