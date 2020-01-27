#!/bin/bash
num=$(($1+1))
for (( i=1; i <num; i++))
do
	sshpass -p "Deloitte1234" scp -r "admin_scalability@Jmeterslave${i}.westeurope.cloudapp.azure.com:/home/admin_scalability/Sharedvolume/" "/home/admin_scalability/"
done
