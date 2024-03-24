#!/usr/bin/env bash
# wget -O build.sh https://raw.githubusercontent.com/DerKleinePunk/CarUiFlutterPi/master/build.sh
# chmod +x build.sh

FILE=logger.sh
if [ ! -f "$FILE" ]; then
    wget -O logger.sh https://raw.githubusercontent.com/DerKleinePunk/CarUiFlutterPi/master/logger.sh
fi

source ./logger.sh
SCRIPTENTRY

echo try to download and build IoBackend and Dependecy
INFO "try to download and build IoBackend and Dependecy"
reproBuild="false"
if [ -d .git ]; then
	echo "called inside repro"
	reproBuild="true"
fi

echo "reproBuild $reproBuild"
INFO "reproBuild $reproBuild"

if [ "$reproBuild" = "false" ] ; then
	wget -O DebianPackages.txt https://raw.githubusercontent.com/DerKleinePunk/CarUiFlutterPi/master/DebianPackages.txt
	exitCode=$?
	if [ $exitCode -ne 0 ] ; then
		echo "wget give an error"
		exit $exitCode
	fi
else
	echo "Don't forget git pull bevor building"
	INFO "Don't forget git pull bevor building"
fi

DEPENSFILE="DebianPackages.txt"

InstallPackage(){
	packageName="$1"
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $packageName|grep "install ok installed")
	DEBUG "Checking for $packageName: $PKG_OK"
	if [ "" = "$PKG_OK" ]; then
		echo "No $packageName. Setting up $packageName."
		DEBUG "No $packageName. Setting up $packageName."
		sudo apt-get --yes --no-install-recommends install $packageName
	fi
}

SCRIPTEXIT