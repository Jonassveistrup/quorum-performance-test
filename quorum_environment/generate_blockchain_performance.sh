array=("168.63.36.25" "168.63.67.155" "168.61.102.124" "168.61.87.200" "168.61.100.121" "168.61.97.247" "51.137.107.133" "51.144.32.55" "51.144.38.49" "51.144.110.93" "137.117.174.220" "52.136.252.105" "51.141.118.214" "51.141.118.195" "51.141.114.160" "51.141.116.252" "51.141.117.74" "40.120.41.60" "40.120.41.164" "40.120.41.159" "51.140.143.208" "40.120.40.150" "20.188.32.56" "52.143.156.140" "40.89.188.60" "40.89.186.100" "40.89.186.156" "20.188.39.57")

#source nodes.sh

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
	echo "screen -S start_node -X stuff 'cd /home/admin_scalability/quorum/fromscratchistanbul/${node_name}/ && PRIVATE_CONFIG=ignore nohup geth --datadir data --nodiscover --nousb --istanbul.blockperiod 1 --syncmode full --cache 14336 --txpool.globalslots 20000 --txpool.globalqueue 20000 --mine --etherbase 0 --minerthreads 3 --verbosity 5 --networkid 10 --rpc --rpcaddr 0.0.0.0 --rpcport 22000 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul --emitcheckpoints --maxpeers 30 --port 30303 2>>node.log &'$(echo -ne '\015')" >> "StartNodeScreen.sh"
	chmod +x StartNodeScreen.sh
	touch StartNode.sh
	echo "PRIVATE_CONFIG=ignore nohup geth --datadir data --nodiscover --nousb --istanbul.blockperiod 1 --syncmode full --cache 14336 --txpool.globalslots 20000 --txpool.globalqueue 20000 --mine --etherbase 0 --minerthreads 3 --verbosity 5 --networkid 10 --rpc --rpcaddr 0.0.0.0 --rpcport 22000 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul --emitcheckpoints --maxpeers 30 --port 30303 2>>node.log &" > "StartNode.sh"
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
done

for (( i=0; i <$1; i++))
do
	node_name="node${i}"
	rm -rf "${node_name}"
done