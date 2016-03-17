#!/bin/bash
# ----------------------------------------------------------------------
# @file intelliPi_x86_installer.sh
# @author IntelliPi team
# @date March 16, 2016
# @purpose Create an installer which installs all of the libraries required
# on an X86 or Raspi host other than that of which using the IntelliPi distro
# ----------------------------------------------------------------------

PKGS_TO_CLONE=()

PKGS_NONX86=("https://github.com/AtlantsEmbedded/nonatlants-wiringPi.git")
PKGS_X86=("https://github.com/AtlantsEmbedded/x86-x64-stub-files.git")

PKGS_GENERIC=( 
"https://github.com/AtlantsEmbedded/atlants-buzzer_lib.git"
"https://github.com/AtlantsEmbedded/atlants-io_csv_lib.git"
"https://github.com/AtlantsEmbedded/atlants-lin_algebra_lib.git"
"https://github.com/AtlantsEmbedded/atlants-signal_proc_lib.git"
"https://github.com/AtlantsEmbedded/atlants-stats_lib.git"
"https://github.com/AtlantsEmbedded/atlants-DATA_preprocessing.git"
"https://github.com/AtlantsEmbedded/atlants-DATA_interface.git"
"https://github.com/AtlantsEmbedded/atlants-braintone_app.git"
)

PKGS_TO_GET=("git"
"build-essential"
"binutils"
"grep"
"automake"
"autoconf"
"libpthread"
"gcc"
"make"
"patch"
"libglib2.0-dev"
)

IP_ADDR_DNS_SERVER="8.8.8.8"
IP_PORT_DNS="53"

function user_input() {
	USER_INPUT=""

	read -n1 -p "# Continue? [y,n]" USER_INPUT 
	case $USER_INPUT in  
		y|Y)  ;; 
		n|N) exit ;; 
		*) echo dont know ;; 
	esac
	
	echo -n ""
}

function system_check() {
	# Check for essential packages (assuming Ubuntu)
	DISTRO=`grep DISTRIB_ID /etc/*-release | awk -F '=' '{print $2}'`
	
	if [ "$DISTRO" == "Ubuntu" ]; then
	  echo  "Assuming Ubuntu-based distribution"
	else
	  echo "Not Ubuntu-based, quitting"
	  exit
	fi
	
	# Check for Internet connectivity
	echo -n "Checking for Internet - "
	nc -z  $IP_ADDR_DNS_SERVER $IP_PORT_DNS >/dev/null 2>&1
	online=$?
	if [ $online -eq 0 ]; then
	    echo "Online"
	else
	    echo "Offline - check for Internet access/connectivity"
	    exit
	fi
	
}

function build_misc_packages() {
	
	wget https://www.pacificsimplicity.ca/sites/default/files/uploads/libezxml-0.8.6.tar.gz
	tar -xzvf libezxml-0.8.6.tar.gz
	`cd ezxml;make;make install`
	
	`cd nonatlants-wiringPi/;./build`
	
}

echo "-----------------------------------------------------------------------"
echo " IntelliPI installer script"
echo "-----------------------------------------------------------------------"
echo ""

# Check for arguments
if [ -z $1 ]; then
	echo "No args given - assuming X86/64"
	PKGS_TO_CLONE+=PKGS_X86
	PKGS_TO_CLONE+=PKGS_GENERIC
	
else
	echo "Arg1 found - assuming RASPBERRYPI"
	PKGS_TO_CLONE+=PKGS_NONX86
	PKGS_TO_CLONE+=PKGS_GENERIC
fi

# Verify system
system_check

user_input

# Install essential packages
echo "Installing required packages "
for i in ${PKGS_TO_GET[@]}; do
        su -c "apt-get install -y ${i}"
done

user_input

# Clone packages
echo "Cloning IntelliPi packages  "
for i in ${PKGS_TO_CLONE[@]}; do
        git clone ${i}
done

user_input

# Build misc packages
build_misc_packages

user_input

# Building packages
echo "Building IntelliPi packages  "
for i in ${PKGS_TO_CLONE[@]}; do
        `cd ${1}; make; make install;`
done

