nscli rest-server --chain-id namechain --trust-node

# Get the sequence and account numbers for jack to construct the below requests
curl -s http://localhost:1317/auth/accounts/$(nscli keys show jack -a) | jq ".result.value.coins[0]"
curl -s http://localhost:1317/auth/accounts/$(nscli keys show alice -a) | jq ".result.value.coins[0]"


# Buy another name for jack, first create the raw transaction
# NOTE: Be sure to specialize this request for your specific environment, also the "buyer" and "from" should be the same address
curl -XPOST -s http://localhost:1317/nameservice/names --data-binary '{"base_req":{"from":"'$(nscli keys show jack -a)'","chain_id":"namechain"},"name":"jack1.id","amount":"5nametoken","buyer":"'$(nscli keys show jack -a)'"}' > unsignedTx.json

# Then sign this transaction
# NOTE: In a real environment the raw transaction should be signed on the client side. Also the sequence needs to be adjusted, depending on what the query of alice's account has shown.
nscli tx sign unsignedTx.json --from jack --offline --chain-id namechain --sequence 1 --account-number 0 > signedTx.json

# And finally broadcast the signed transaction
nscli tx broadcast signedTx.json
# > { "height": "266", "txhash": "C041AF0CE32FBAE5A4DD6545E4B1F2CB786879F75E2D62C79D690DAE163470BC", "logs": [  {   "msg_index": "0",   "success": true,   "log": ""  } ],"gas_wanted":"200000", "gas_used": "41510", "tags": [  {   "key": "action",   "value": "buy_name"  } ]}

# Set the data for that name that jack just bought
# NOTE: Be sure to specialize this request for your specific environment, also the "owner" and "from" should be the same address
$ curl -XPUT -s http://localhost:1317/nameservice/names --data-binary '{"base_req":{"from":"'$(nscli keys show jack -a)'","chain_id":"namechain"},"name":"jack1.id","value":"8.8.4.4","owner":"'$(nscli keys show jack -a)'"}' > unsignedTx.json
# > {"check_tx":{"gasWanted":"200000","gasUsed":"1242"},"deliver_tx":{"log":"Msg 0: ","gasWanted":"200000","gasUsed":"1352","tags":[{"key":"YWN0aW9u","value":"c2V0X25hbWU="}]},"hash":"B4DF0105D57380D60524664A2E818428321A0DCA1B6B2F091FB3BEC54D68FAD7","height":"26"}

# Again we need to sign and broadcast
nscli tx sign unsignedTx.json --from jack --offline --chain-id namechain --sequence 2 --account-number 0 > signedTx.json
nscli tx broadcast signedTx.json

# Query the value for the name jack just set
$ curl -s http://localhost:1317/nameservice/names/jack1.id
# 8.8.4.4

# Query whois for the name jack just bought
$ curl -s http://localhost:1317/nameservice/names/jack1.id/whois
# > {"value":"8.8.8.8","owner":"cosmos127qa40nmq56hu27ae263zvfk3ey0tkapwk0gq6","price":[{"denom":"STAKE","amount":"10"}]}

# Alice buys name from jack
$ curl -XPOST -s http://localhost:1317/nameservice/names --data-binary '{"base_req":{"from":"'$(nscli keys show alice -a)'","chain_id":"namechain"},"name":"jack1.id","amount":"10nametoken","buyer":"'$(nscli keys show alice -a)'"}' > unsignedTx.json

# Again we need to sign and broadcast
# NOTE: The account number has changed to 1 and the sequence is now 2, according to the query of alice's account
nscli tx sign unsignedTx.json --from alice --offline --chain-id namechain --sequence 2 --account-number 1 > signedTx.json
nscli tx broadcast signedTx.json
# > { "height": "1515", "txhash": "C9DCC423E10E7E5E40A549057A4AA060DA6D6A885A394F6ED5C0E40AEE984A77", "logs": [  {   "msg_index": "0",   "success": true,   "log": ""  } ],"gas_wanted": "200000", "gas_used": "42375", "tags": [  {   "key": "action",   "value": "buy_name"  } ]}

# Now, Alice no longer needs the name she bought from jack and hence deletes it
# NOTE: Only the owner can delete the name. Since she is one, she can delete the name she bought from jack
$ curl -XDELETE -s http://localhost:1317/nameservice/names --data-binary '{"base_req":{"from":"'$(nscli keys show alice -a)'","chain_id":"namechain"},"name":"jack1.id","owner":"'$(nscli keys show alice -a)'"}' > unsignedTx.json

# And a final time sign and broadcast
# NOTE: The account number is still 1, but the sequence is changed to 3, according to the query of alice's account
nscli tx sign unsignedTx.json --from alice --offline --chain-id namechain --sequence 3 --account-number 1 > signedTx.json
nscli tx broadcast signedTx.json

# Query whois for the name Alice just deleted
$ curl -s http://localhost:1317/nameservice/names/jack1.id/whois
# > {"value":"","owner":"","price":[{"denom":"STAKE","amount":"1"}]}