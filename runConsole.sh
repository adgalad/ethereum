#!/bin/bash
geth --rpc --rpcaddr "0.0.0.0" --rpccorsdomain "*" --networkid 1234 --datadir=$ethereum_home/$1 --rpcapi="db,eth,net,web3,personal,web3"  console ${@:2} #2> /dev/null
