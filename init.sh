#!/bin/sh

set -e

nsd unsafe-reset-all

rm -rf ~/.nsd
rm -rf ~/.nscli

nsd init test --chain-id=namechain

nscli config output json
nscli config indent true
nscli config trust-node true
nscli config chain-id namechain
nscli config keyring-backend test

# nscli config node tcp://0.0.0.0:26657

nscli keys add jack
nscli keys add alice

nsd add-genesis-account $(nscli keys show jack -a) 1000nametoken,100000000stake
nsd add-genesis-account $(nscli keys show alice -a) 1000nametoken,100000000stake

nsd gentx --name jack --keyring-backend test

echo "Collecting genesis txs..."
nsd collect-gentxs

echo "Validating genesis file..."
nsd validate-genesis

# 0.0.0.0:26657 instead of default 127.0.0.1:26657
nsd start --rpc.laddr=tcp://0.0.0.0:26657