#reads from file nodes.sh
#source nodes.sh

array=("168.63.36.25" "168.63.67.155" "168.61.102.124" "168.61.87.200" "168.61.100.121" "168.61.97.247" "51.137.107.133" "51.144.32.55" "51.144.38.49" "51.144.110.93" "137.117.174.220" "52.136.252.105" "51.141.118.214" "51.141.118.195" "51.141.114.160" "51.141.116.252" "51.141.117.74" "40.120.41.60" "40.120.41.164" "40.120.41.159" "51.140.143.208" "40.120.40.150" "20.188.32.56" "52.143.156.140" "40.89.188.60" "40.89.186.100" "40.89.186.156" "20.188.39.57")

for (( i=0; i <$1; i++))
do
  node_name="node${i}"
  node_ip="${array[$i]}"
  sshpass -p "Deloitte1234" ssh -o StrictHostKeyChecking=no -t "admin_scalability@${node_ip}" "screen -wipe"
  sshpass -p "Deloitte1234" ssh -t "admin_scalability@${node_ip}" "cd /home/admin_scalability/quorum/fromscratchistanbul/node* && rm node.log nohup.out"
done




