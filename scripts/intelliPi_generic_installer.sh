#!/bin/bash
# ----------------------------------------------------------------------
# @file intelliPi_x86_installer.sh
# @author IntelliPi team
# @date March 16, 2016
# @purpose Create an installer which installs all of the libraries required
# on an X86 or Raspi host other than that of which using the IntelliPi distro
# ----------------------------------------------------------------------
rm -rf atlants* nonatlants*

PKGS_NONX86=( "https://github.com/AtlantsEmbedded/nonatlants-wiringPi.git" )
PKGS_X86=( "https://github.com/AtlantsEmbedded/nonatlants-wiringPi-stub.git" )

PKGS_GENERIC=( 
"https://github.com/AtlantsEmbedded/nonatlants-ezxml.git"
"https://github.com/AtlantsEmbedded/atlants-buzzer_lib.git"
"https://github.com/AtlantsEmbedded/atlants-io_csv_lib.git"
"https://github.com/AtlantsEmbedded/atlants-signal_proc_lib.git"
"https://github.com/AtlantsEmbedded/atlants-stats_lib.git"
"https://github.com/AtlantsEmbedded/atlants-DATA_preprocessing.git"
"https://github.com/AtlantsEmbedded/atlants-DATA_interface.git"
"https://github.com/AtlantsEmbedded/atlants-braintone_app.git"
)


PKGS_GENERIC_LOC_DIR=( 
"nonatlants-ezxml"
"atlants-buzzer_lib"
"atlants-io_csv_lib"
"atlants-signal_proc_lib"
"atlants-stats_lib"
"atlants-DATA_preprocessing"
"atlants-DATA_interface"
"atlants-braintone_app"
)

BRAINTONE_SCRIPTS_SRC="atlants-braintone_app/scripts/launch_braintone_x86.sh"
BRAINTONE_SCRIPTS_DEST="launch_braintone_x86.sh"

PKGS_TO_GET=("git"
"build-essential"
"binutils"
"grep"
"automake"
"autoconf"
"gcc"
"make"
"patch"
"libglib2.0-dev"
"libbluetooth-dev"
"bluez"
"bluez-utils"
"bluez-tools"
)

IP_ADDR_DNS_SERVER="8.8.8.8"
IP_PORT_DNS="53"

function user_input() {
	USER_INPUT=""

	echo -en '\E[00;31m' "# Continue? [y,n]" 
	read USER_INPUT 
	case $USER_INPUT in  
		y|Y)  ;; 
		n|N) exit ;; 
		*) echo dont know ;; 
	esac
	
	tput sgr0
	echo ""
}

function system_check() {
	
	if sudo -n true 2>/dev/null; then 
		echo "Running and active sudo session - continue"
	else
		echo "Not running with an active sudo session"
		echo "Enter password and press enter"
		sudo -Sv -p ''
		echo $?
		if [ $? -eq 1 ]; then
			echo "Unable to create sudo session - quitting"
			exit
		else
			echo "Sudo session now open"
		fi
	fi
	
	# Check for essential packages (assuming Ubuntu)
	DISTRO=`grep DISTRIB_ID /etc/*-release | awk -F '=' '{print $2}'`
	
	if [ "$DISTRO" == "Ubuntu" ]; then
	  echo  "Assuming Ubuntu-based distribution"
	elif [ "$DISTRO" == "Debian" ]; then
	echo  "Assuming Debian-based distribution"
	else
	  echo "Not Ubuntu-based/Debian, quitting"
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
	
	if [ -z $1 ]; then
		( cd nonatlants-wiringPi-stub/ && make && sudo make install)
	else
		(cd nonatlants-wiringPi/ && ./build )
	fi
}

echo -en '\E[00;32m' "-----------------------------------------------------------------------\n"
tput sgr0 
echo -en '\E[00;32m' " IntelliPI installer script                                            \n"
tput sgr0 
echo -en '\E[00;32m' "-----------------------------------------------------------------------\n"
tput sgr0 
echo ""

# Verify system
system_check

# Install essential packages
echo -en '\E[00;32m' "-----------------------------------------------------------------------\n"
echo -e '\E[00;32m' "Installing required packages "
echo -en '\E[00;32m' "-----------------------------------------------------------------------\n"

user_input
for i in ${PKGS_TO_GET[@]}; do
	sudo apt-get install -y ${i}
done

# Clone packages
echo -en '\E[00;32m' "-----------------------------------------------------------------------\n"
echo -e '\E[00;32m' "Cloning IntelliPi packages  "
echo -en '\E[00;32m' "-----------------------------------------------------------------------\n"

user_input

# Check for arguments
if [ -z $1 ]; then
	echo "No args given - assuming X86/64"
	for i in ${PKGS_X86[@]}; do
        git clone ${i}
	done
else
	echo "Arg1 found - assuming RASPBERRYPI"
	for i in ${PKGS_NONX86[@]}; do
        git clone ${i}
	done
fi

for i in ${PKGS_GENERIC[@]}; do
        git clone ${i}
done


# Build misc packages
echo -en '\E[00;32m' "-----------------------------------------------------------------------\n"
echo -e '\E[00;32m' "Building misc packages  "
echo -en '\E[00;32m' "-----------------------------------------------------------------------\n"
tput sgr0 
user_input
build_misc_packages


# Building packages
echo -en '\E[00;32m' "-----------------------------------------------------------------------\n"
echo -e '\E[00;32m' "Building IntelliPi packages  "
echo -en '\E[00;32m' "-----------------------------------------------------------------------\n"
tput sgr0 

user_input
for i in ${PKGS_GENERIC_LOC_DIR[@]}; do
	echo -e '\E[00;32m' "Building $i"
	tput sgr0
	( cd $i && make && sudo make install;)
done

cp $BRAINTONE_SCRIPTS_SRC $BRAINTONE_SCRIPTS_DEST 
