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
        echo -e "\033[1;32m run $0 -h for additional information 033[0m"
        ;;
        *)
        echo "\033[1;31mInstallation interrupted\033[0m"
        echo -e "\033[1;32m run $0 -h for additional information 033[0m"
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

### Help

help()
{
echo -e "\033[1;36m========================================\033[0m"
echo -e "\033[1;33m Automated TOR Connection Script \033[0m"
echo -e "\033[1;36m========================================\033[0m"
echo ""
echo -e "\033[1;32mThis script automates the process of establishing a connection over TOR.\033[0m"
echo -e "\033[1;32mIt saves you time by avoiding manual installation of components.\033[0m"
echo ""
echo -e "\033[1;34m- You must use \033[1;31msudo\033[1;34m to ensure correct installation of all components.\033[0m"
echo -e "\033[1;34m- To set the proxy for the current terminal session, you need to \033[1;31msource $0\033[1;34m the script.\033[0m"
echo -e "\033[1;34m  Example: \033[1;31msource $0\033[0m"
echo -e "\033[1;34m- Running the script without options will simply start its regular functionality.\033[0m"
echo ""
echo -e "\033[1;34mUsage:\033[0m"
echo -e "  \033[1;31msudo\033[0m $0 [\033[1;32moptions\033[0m]"
echo ""
echo -e "\033[1;34mOptions:\033[0m"
echo -e "  \033[1;32m-f\033[0m   \033[1;37mFull installation (installs TOR, obfs4proxy, privoxy)\033[0m"
echo -e "  \033[1;32m-b\033[0m   \033[1;37mAdd bridges to the /etc/tor/torrc file\033[0m"
echo -e "  \033[1;32m-h\033[0m   \033[1;37mDisplay this help message\033[0m"
echo ""
echo -e "\033[1;34mWritten by: \033[4;35ma11eyezonme\033[0m"
echo -e "\033[1;36m========================================\033[0m"
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
    echo "UseBridges 1" >> /etc/tor/torrc
    echo "ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy" >> /etc/tor/torrc
    sudo sed -i '/#        forward-socks5t/s/^#//g' /etc/privoxy/config
    bridges
    ;;
    -h)
    help
    exit 1
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
elif [[ -n $(service $VAR status | grep 'active' ) ]]
then
    echo "$VAR already started, restarting..."
    service $VAR restart
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
