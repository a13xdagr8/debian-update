#!/bin/bash

### Update script for Debian based distros.
### Tested on Ubuntu and Kali Linux

## colors
yel=$'\e[1;33m'
gre=$'\e[1;32m'
cya=$'\e[0;36m'
end=$'\e[0m'

## check to see if running as root
if [[ ! $(id -u) -eq 0 ]]; then
    echo "[*] Script must run with root priviledges."
    exit 1
fi

echo "${gre}===================================${end}"
echo "${yel}[-]      apt Update Script      [-]${end}"
echo "${gre}===================================${end}"
echo "${yel}Last update was:${end} $(less /var/log/apt/history.log | grep 'Commandline: apt upgrade -y' -B1 | tail -2 | head -1 | awk '{print $2}')"
echo

echo "${yel}[+] Searching for updates...${end}"
## check to see if updates are available
if [[ $(apt update 2> /dev/null | grep "All packages are up to date") ]]; then
    echo "${gre}[-] Nothing to update. All packages are up to date.${end}"
    exit 0
else
    echo "${gre}[*] Packages to update/upgrade:${end}"
    apt list --upgradable
fi

f_cleanup(){
    echo "${yel}[+] Cleaning...${end}"
    ## remove packages that were automatically installed to satisfy dependencies for other packages and are now no longer
    ## needed as dependencies changed or the package(s) needing them were removed in the meantime.
    apt autoremove -y
    ## check if a reboot is required
    ls /var/run/ | grep -i "required"
    echo "${gre}[*] Update complete${end}"
}

## select between apt upgrade or apt full-upgrade
echo
echo "${yel}[+] Update Options [+]${end}"
echo
echo "${cya} [1] [upgrade] Install available upgrades of all packages currently installed.${end}"
echo "${cya} [2] [full-upgrade] Same as upgrade, but will remove currently installed packages if this is needed to upgrade the system as a whole.${end}"
echo
read -p "${yel}Choice: ${end}" choice

case ${choice} in
    1)  echo "${yel}[+] Upgrading packages...${end}"; apt upgrade -y; f_cleanup ;;
    2)  echo "${yel}[+] Upgrading packages...${end}"; apt full-upgrade -y; f_cleanup ;;
esac