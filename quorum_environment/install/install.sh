sudo add-apt-repository ppa:longsleep/golang-backports --yes
sudo apt-get update --yes
sudo apt-get install golang-go --yes

git clone https://github.com/jpmorganchase/quorum.git
cd quorum
make all
export PATH=$(pwd)/build/bin:$PATH


mkdir fromscratchistanbul
cd fromscratchistanbul
git clone https://github.com/jpmorganchase/istanbul-tools.git
cd istanbul-tools
make