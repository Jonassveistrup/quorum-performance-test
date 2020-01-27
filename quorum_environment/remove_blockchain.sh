#reads from file nodes.sh
source nodes.sh


for (( i=0; i <$1; i++))
do
	 node_name="node${i}"
	 node_ip="${array[$i]}"
	 sshpass -p "Deloitte1234" ssh -o StrictHostKeyChecking=no -t "admin_scalability@${node_ip}" "screen -wipe"
	 sshpass -p "Deloitte1234" ssh -t "admin_scalability@${node_ip}" "killall -INT geth"
	 sshpass -p "Deloitte1234" ssh -t "admin_scalability@${node_ip}" "screen -X -S start_node quit"
	 sshpass -p "Deloitte1234" ssh -t "admin_scalability@${node_ip}" "cd /home/admin_scalability/quorum/fromscratchistanbul/ && rm -rf ${node_ip}"
done




