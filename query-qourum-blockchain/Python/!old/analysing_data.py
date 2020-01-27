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
import sys

regex = r"<httpSample ts=\"(\d*)\">\n  <responseData.*(0x.{64}).*&.*\n</responseData>\n</httpSample>"

# Example,  python3.6 analysing_data.py 23.102.56.29 '28 nodes_5 slaves_1000 users_10 kb bytes.xml' '28_nodes_5_slaves_1000_users_10_kb_bytes.txt'

print(sys.argv)
ip_address = sys.argv[1]

w3 = Web3(HTTPProvider("http://"+ ip_address +":22000"))

w3.middleware_onion.inject(geth_poa_middleware, layer=0)

def block_from_transaction(_tx_hash):
	try:
		block_number = w3.eth.getTransaction(_tx_hash)['blockNumber']
	except:
		return -1
	return block_number

def block_time_stamp(_block_number):
	if _block_number == -1:
		return 0
	time_stamp = w3.eth.getBlock(_block_number)['timestamp']
	return time_stamp

# Generate list of hashes
input_file = sys.argv[2] #"res.xml"
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
	t = block_to_time[tx[2]]
	if t == 0:
		res_tuple = (tx[0], tx[1], "None")		
		tx_to_time.append(res_tuple)
	else: 
		res_tuple = (tx[0], tx[1], t*1000)
		tx_to_time.append(res_tuple)

f = open(sys.argv[3], 'w+')
for tx in tx_to_time:
	f.write(str(tx[0]) + ", " + str(tx[1]) +", " + str(tx[2]) + "\n")
f.close()
