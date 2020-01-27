#!/bin/bash
sudo apt-get install  curl  apt-transport-https ca-certificates software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce
USER_DOCKER=$(getent passwd {1000..60000} | grep "/bin/bash" | awk -F: '{ print $1}')
sudo usermod -aG docker $USER_DOCKER
sudo su
HostIP=$(ip route show | awk '/default/ {print $9}') \
&& docker pull dragoscampean/testrepo:jmetruslave \
&& docker run -dit --name slave --network host -e HostIP=$HostIP -e Xms=256m -e Xmx=14336m -e MaxMetaspaceSize=4096m -v /home/admin_scalability/Sharedvolume:/opt/Sharedvolume dragoscampean/testrepo:jmetruslave /bin/bash