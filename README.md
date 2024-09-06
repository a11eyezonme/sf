 Automated TOR Connection Script 
========================================

This script automates the process of establishing a connection over TOR.
It saves you time by avoiding manual installation of components.

- You must use sudo to ensure correct installation of all components.
- To set the proxy for the current terminal session, you need to source ./tor-start.sh the script.
  Example: source ./tor-start.sh
- Running the script without options will simply start its regular functionality.

Usage:
  sudo ./tor-start.sh [options]

Options:
  -f   Full installation (installs TOR, obfs4proxy, privoxy)
  -b   Add bridges to the /etc/tor/torrc file
  -h   Display this help message

========================================
