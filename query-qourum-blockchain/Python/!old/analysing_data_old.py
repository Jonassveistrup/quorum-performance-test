# What was needed to run this?
# sudo add-apt-repository ppa:deadsnakes/ppa
# sudo apt install python3.7
# python -m ensurepip --default-pip
# sudo apt-get install python3-dev
# sudo apt-get install libssl-dev
# sudo apt-get install python3-pip
# sudo python3 -m pip install web3

from web3 import Web3, HTTPProvider, IPCProvider, WebsocketProvider
from web3.middleware import geth_poa_middleware

import re

regex = r"<httpSample ts=\"(\d*)\">\n  <responseData.*(0x.{64}).*&.*\n</responseData>\n</httpSample>"

w3 = Web3(HTTPProvider("http://51.104.16.74:22000"))

w3.middleware_onion.inject(geth_poa_middleware, layer=0)


def block_from_transaction(_tx_hash):
	try:
		block_number = w3.eth.getTransaction(_tx_hash)['blockNumber']
	except:
		print("shit")
		return -1
	return block_number

def block_time_stamp(_block_number):
	if _block_number == -1:
		return 0
	time_stamp = w3.eth.getBlock(_block_number)['timestamp']
	return time_stamp

# Generate list of hashes
input_file = "res.xml"
with open(input_file, 'r', encoding='utf-8') as f:
	data = f.read()
regex_result = re.findall(regex, data)

txs = []
for statement in regex_result:
	tx_time = statement[0]
	tx_hash = statement[1]
	tx_tuple = (tx_hash, tx_time)
	txs.append(tx_tuple)


tx_to_block = []
blocks = {}
block_to_time = {}
tx_to_time = []

for i in range(len(txs)):
	tx_hash = txs[i][0]
	tx_start_time = txs[i][1]
	tx_block_number = block_from_transaction(tx_hash)
	tx_to_block_tuple = (tx_hash, tx_start_time, tx_block_number)
	tx_to_block.append(tx_to_block_tuple)
	blocks[tx_block_number] = True

for block_number in blocks.keys():
	block_time = block_time_stamp(block_number)
	block_to_time[block_number] = block_time

for tx in tx_to_block:
	res_tuple = (tx[0], tx[1], block_to_time[tx[2]])
	tx_to_time.append(res_tuple)

f = open('analysis.txt', 'w+')
for tx in tx_to_time:
	f.write(str(tx[0]) + ", " + str(tx[1]) +", " + str(tx[2]*1000) + "\n")
f.close()
