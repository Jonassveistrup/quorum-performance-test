#array=("13.74.12.81" "51.141.97.239" "40.69.199.8")
array=("52.169.147.128" "51.145.132.236" "40.89.153.190" "51.11.35.212")

for (( i=0; i < $1; i++))
do
	node_name="node${i}"
	mkdir "$node_name"
done

cd "node0"
chmod +x "../istanbul-tools/build/bin/istanbul"
"../istanbul-tools/build/bin/istanbul" setup --num $1 --nodes --quorum --save --verbose

cd ..
for (( i=0; i <$1; i++))
do
	node_name="node${i}"
	mkdir -p "${node_name}/data/geth"
	geth --datadir "${node_name}/data" account new --password <(echo "Deloitte")
	cp "node0/genesis.json" "${node_name}"
	cp "node0/${i}/nodekey" "${node_name}/data/geth"
	cd "$node_name"
	geth --datadir data init genesis.json
	touch StartNodeScreen.sh
	echo "screen -d -m -S start_node" > "StartNodeScreen.sh"
	echo "screen -S start_node -X stuff 'export PATH=/home/admin_scalability/quorum/build/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:'$(echo -ne '\015')" >> "StartNodeScreen.sh"
	echo "screen -S start_node -X stuff 'cd /home/admin_scalability/quorum/fromscratchistanbul/${node_name}/ && PRIVATE_CONFIG=ignore nohup geth --datadir data --nodiscover --nousb --istanbul.blockperiod 1 --syncmode start  --cache 4096 --mine --minerthreads 1 --verbosity 5 --networkid 10 --rpc --rpcaddr 0.0.0.0 --rpcport 22000 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul --emitcheckpoints --port 30303 2>>node.log &'$(echo -ne '\015')" >> "StartNodeScreen.sh"
	chmod +x StartNodeScreen.sh
	touch StartNode.sh
	echo "PRIVATE_CONFIG=ignore nohup geth --datadir data --nodiscover --nousb --istanbul.blockperiod 1 --syncmode fast --cache 4096 --mine --minerthreads 1 --verbosity 5 --networkid 10 --rpc --rpcaddr 0.0.0.0 --rpcport 22000 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul --emitcheckpoints --port 30303 2>>node.log &" > "StartNode.sh"
	chmod +x StartNode.sh
	cd ..
done

cd node0
cp static-nodes.json temp1.json
cp static-nodes.json temp2.json

for (( i=0; i < $1; i++))
do
	node_ip="${array[$i]}"
	sed "0,/@0.0.0.0/{s/@0.0.0.0/@${node_ip}/}" temp1.json > temp2.json
	cat temp2.json > temp1.json
done
cat temp1.json > static-nodes.json
rm temp1.json temp2.json
cd ..

for (( i=0; i <$1; i++))
do
	node_name="node${i}"
	node_ip="${array[$i]}"
	cp "node0/static-nodes.json" "${node_name}/data"
	sshpass -p "Deloitte1234" scp -r "$node_name" "admin_scalability@${node_ip}:/home/admin_scalability/quorum/fromscratchistanbul"
	#sshpass -p "Deloitte1234" ssh -t "admin_scalability@${node_ip}" "cd /home/admin_scalability/quorum/fromscratchistanbul/${node_name} && ./StartNodeScreen.sh"
done

for (( i=0; i <$1; i++))
do
	node_name="node${i}"
	rm -rf "${node_name}"
done

#sshpass -p "password" scp -r user@example.com:/some/remote/path /some/local/path