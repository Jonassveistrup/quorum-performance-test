#!/bin/bash
sudo su
HostIP=$(ip route show | awk '/default/ {print $9}') \
&& docker pull dragoscampean/testrepo:jmetruslave \
&& docker run -dit --name slave --network host -e HostIP=$HostIP -e Xms=256m -e Xmx=14336m -e MaxMetaspaceSize=4096m -v /home/admin_scalability/Sharedvolume:/opt/Sharedvolume dragoscampean/testrepo:jmetruslave /bin/bash