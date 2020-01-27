# What was needed to run this?
# sudo add-apt-repository ppa:deadsnakes/ppa
# sudo apt install python3.7
# python -m ensurepip --default-pip
# sudo apt-get install python3-dev
# sudo apt-get install libssl-dev
# sudo apt-get install python3-pip
# sudo python3 -m pip install web3

import re
import sys

from web3 import Web3, HTTPProvider, IPCProvider, WebsocketProvider
from web3.middleware import geth_poa_middleware

regex = r"<httpSample ts=\"(\d*)\">\n  <responseData.*(0x.{64}).*&.*\n</responseData>\n</httpSample>"

# Example,  python3.6 PythonGethGetter.py 23.102.56.29 'mem_res.xml' 'mem_res.txt'

print(sys.argv)
ip_address = sys.argv[1]

w3 = Web3(HTTPProvider("http://"+ ip_address +":22000"))
w3.middleware_onion.inject(geth_poa_middleware, layer=0)


block_timestamps = {} # mapping from block number to timestamp
block_transactions = {} # Mapping from block numbers as keys, to the transaction-hashes in a list.
block_number_of_transaction = {}
transaction_to_block = {} # Mapping from transaction-hashes to block 

output_lines = [] # a list of tuples, the tuple should be (hash, send_timestamp, included_timestamp, blocknumber, transactions in block)

def load_transaction(_tx_hash, _tx_start_time):
	'''
		Loads the transaction and fills in the values.
		If the transaction does not exist in the transaction_to_block, we must load the entire block,
	'''
	if not(_tx_hash in transaction_to_block): 
		print(_tx_hash)
		# The block is new, load block and read data 
		block_number = w3.eth.getTransaction(_tx_hash)['blockNumber'] # Load the blocknumber
		block = w3.eth.getBlock(block_number) # Load the block
		time_stamp = block['timestamp'] # read the block timestamp

		block_timestamps[block_number] = time_stamp * 1000 # recall that ethereum and queorum stores timestamps in seconds and not milliseconds
		block_transactions = block['transactions']

		block_number_of_transaction[block_number] = len(block_transactions)

		for transaction in block_transactions:
			#print(transaction, transaction.hex())
			transaction_to_block[transaction.hex()] = block_number

	# Create the output line 
	tx_block_number = transaction_to_block[_tx_hash]
	tx_include_time = block_timestamps[tx_block_number]
	tx_block_number_count = block_number_of_transaction[tx_block_number]

	data_tuple = (_tx_hash, _tx_start_time, tx_include_time, tx_block_number, tx_block_number_count)
	output_lines.append(data_tuple)

input_file = sys.argv[2] #"res.xml"
with open(input_file, 'r', encoding='utf-8') as f:
	data = f.read()
regex_result = re.findall(regex, data)

for statement in regex_result:
	tx_time = statement[0]
	tx_hash = statement[1]

	load_transaction(tx_hash, tx_time)


f = open(sys.argv[3], 'w+')
for tx in output_lines:
	f.write(str(tx[0]+", "+ str(tx[1]) + ", " + str(tx[2]) + ", " + str(tx[3]) + ", " + str(tx[4])) + "\n")
f.close()