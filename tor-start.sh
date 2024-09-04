#!/bin/bash

### Check Installed dependencies 

check_installation()
{
VAR=$1    
if 
    [[ -n $(command -v $VAR) ]]
then
    echo -e "\033[1;32m$VAR installed, continue...\033[0m"
else
    echo -e "\033[1;31m$VAR not found\033[0m"
    read -p "Would you like to install $VAR?(Y/n): " answer
    case $answer in
        [Yy])
        echo -e "\033[1;32mInstallation...033[0m"
        apt install $VAR
        ;;
        [Nn])
        echo -e "\033[1;31mInstallation interrupted. A $VAR must be installed for the script to work.\033[0m"
        ;;
        *)
        echo "\033[1;31mInstallation interrupted\033[0m"
        ;;
    esac
fi
}

### Configure bridges

bridges()
{
read -p "Would you like to add bridges to the /etc/tor/torrc? (Y/n): " ask
case $ask in 
    [Yy]*)
        while true; do
            read -p "Enter your bridges or 'q' to continue.. : " brd
            if [[ $brd == 'q' ]]; then
                break
            else
                echo $brd | sed 's|^|Bridge |' >> /etc/tor/torrc
            fi
        done
    ;;
    *)
        echo "Skipping bridge configuration."
    ;;
esac
}

### Check argument

for arg in $@
do
    case $arg in
    -b)
    bridges 
    exit 1
    ;;
    -f)
    check_installation tor
    check_installation obfs4proxy
    check_installation privoxy
    bridges
    echo "UseBridges 1" >> /etc/tor/torcc
    echo "ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy" >> /etc/tor/torcc
    sudo sed -i '/#        forward-socks5t/s/^#//g' /etc/privoxy/config
    ;;
    *)
    echo "specify argument"
    exit 1
    ;;
    esac
done

   #check_installation tor
   #check_installation obfs4proxy
   #check_installation privoxy
   #bridges


### Check services status

echo -e "Your Current IP ---> \033[1;36m$(wget -qO - https://api.ipify.org)\033[0m"

chk_srv()
{
VAR=$1
if [[ -n $(service $VAR status | grep 'inactive') ]]
then
    service $VAR start
    echo "Starting $VAR service..."
fi
}

chk_srv tor
chk_srv privoxy

GRP=$(journalctl -ext Tor | grep 'Bootstrapped' | awk '{print $7}' | tail -1)
while [[ $GRP != '100%' ]]
do
    sleep 15
    echo -e "Bootstrapped status: \033[0;31m$GRP\033[0m"
    GRP=$(journalctl -ext Tor | grep 'Bootstrapped' | awk '{print $7}' | tail -1)   
done

echo "==============="
echo -e "\033[1;32mBridge is ready\033[0m"
echo "==============="
export http_proxy="http://127.0.0.1:8118"
export https_proxy="https://127.0.0.1:8118"
echo -e "Your Current TOR IP ---> \033[1;35m$(wget -qO - https://api.ipify.org)\033[0m"