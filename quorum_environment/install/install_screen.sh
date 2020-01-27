screen -d -m -S automate_me
screen -S automate_me -X stuff './install.sh'$(echo -ne '\015')