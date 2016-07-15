#!/bin/sh
###############################################################################################
#                                   Tecmint_monitor.sh                                        #
# Written for Tecmint.com for the post www.tecmint.com/linux-server-health-monitoring-script/ #
# If any bug, report us in the link below                                                     #
# Free to use/edit/distribute the code below by                                               #
# giving proper credit to Tecmint.com and Author                                              #
#                                                                                             #
###############################################################################################

clear
# unset any variable which system may be using
unset tecreset os architecture kernelrelease internalip externalip nameserver loadaverage

#
# Check for CURL availiability, a dependency of this script
#
CURL_CMD=$(which curl)
if [ ! -f ${CURL_CMD} ]; then
	echo "CURL not availiable or not installed, fix prior running"
	exit 1
fi

#
# Parse Command Line arguments
#
while getopts iv name
do
        case $name in
          i)iopt=1;;
          v)vopt=1;;
          *)echo "Invalid arg";;
        esac
done

#
# Install
#
if [[ ! -z $iopt ]]; then 
	fail_msg="Installation failed"
	ok_msg="Congratulations! Script Installed, now run monitor Command"
	wd=$(pwd)
	basename "$(test -L "$0" && readlink "$0" || echo "$0")" > /tmp/scriptname
	scriptname=$(echo -e -n $wd/ && cat /tmp/scriptname)
	su -c "cp $scriptname /usr/bin/monitor" root && echo ${ok_message} || echo ${fail_msg}
	# cleanup after install
	rm -f /tmp/scriptname
fi


#
# Show version info
#
if [[ ! -z $vopt ]]; then
	echo -e "tecmint_monitor version 0.1.1\nDesigned by Tecmint.com\nReleased Under Apache 2.0 License"
fi

#
# Monitoring
#
if [[ $# -eq 0 ]]; then


	# Define Variable tecreset
	tecreset=$(tput sgr0)

	# Check if connected to Internet or not
	ping -c 1 google.com &> /dev/null && echo -e '\E[32m'"Internet: $tecreset Connected" || echo -e '\E[32m'"Internet: $tecreset Disconnected"

	# Check OS Type
	os=$(uname -o)
	echo -e '\E[32m'"Operating System Type :" $tecreset $os


	# Check OS Release Version and Name
	if [ -f /etc/os-release ]; then 
		cat /etc/os-release | grep 'NAME\|VERSION' | grep -v 'VERSION_ID' | grep -v 'PRETTY_NAME' > /tmp/osrelease
		echo -n -e '\E[32m'"OS Name :" $tecreset  && cat /tmp/osrelease | grep -v "VERSION" | cut -f2 -d\"
		echo -n -e '\E[32m'"OS Version :" $tecreset && cat /tmp/osrelease | grep -v "NAME" | cut -f2 -d\"
	else
		echo -n -e '\E[32m'"OS Name :"  $tecreset " **** NOT YET AVAILIABLE, Work in Progress ****\n"
		echo -n -e '\E[32m'"OS Version :" $tecreset " **** NOT YET AVAILIABLE, Work in Progress ****\n"
	fi

	# Check Architecture
	architecture=$(uname -m)
	echo -e '\E[32m'"Architecture :" $tecreset $architecture

	# Check Kernel Release
	kernelrelease=$(uname -r)
	echo -e '\E[32m'"Kernel Release :" $tecreset $kernelrelease

	# Check hostname
	echo -e '\E[32m'"Hostname :" $tecreset $HOSTNAME

	# Check Internal IP
	internalip=$(hostname -i)
	echo -e '\E[32m'"Internal IP :" $tecreset $internalip

	# Check External IP
	externalip=$(curl -s ipecho.net/plain;echo)
	echo -e '\E[32m'"External IP : $tecreset "$externalip

	# Check DNS
	nameservers=$(cat /etc/resolv.conf |grep -v '#'| sed '1 d' | awk '{print $2}')
	echo -e '\E[32m'"Name Servers :" $tecreset $nameservers 

	# Check Logged In Users
	who>/tmp/who
	echo -e '\E[32m'"Logged In users :" $tecreset && cat /tmp/who 

	# Check RAM and SWAP Usages
	free -h | grep -v + > /tmp/ramcache
	echo -e '\E[32m'"Ram Usages :" $tecreset
	cat /tmp/ramcache | grep -v "Swap"
	echo -e '\E[32m'"Swap Usages :" $tecreset
	cat /tmp/ramcache | grep -v "Mem"

	# Check Disk Usages
	df -h| grep 'Filesystem\|/dev/sda*' > /tmp/diskusage
	echo -e '\E[32m'"Disk Usages :" $tecreset 
	cat /tmp/diskusage

	# Check Load Average, get data from /proc . This might not work outsude Linux.
	loadaverage=$(cat /proc/loadavg |  awk '{printf("%s %s %s",$1,$2,$3)}')
	echo -e '\E[32m'"Load Average :" $tecreset $loadaverage

	# Check System Uptime
	tecuptime=$(uptime | awk '{print $3,$4}' | cut -f1 -d,)
	echo -e '\E[32m'"System Uptime Days/(HH:MM) :" $tecreset $tecuptime

	# Unset Variables
	unset tecreset os architecture kernelrelease internalip externalip nameserver loadaverage

	# Remove Temporary Files
	temp_files="/tmp/osrelease /tmp/who /tmp/ramcache /tmp/diskusage"
	for i in ${temp_files}; do 
		# check if file exists prior removing.
		if [ -f ${i} ]; then
			rm ${i}
		fi
	done

fi
shift $(($OPTIND -1))
