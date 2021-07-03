#!/bin/bash

#MINIMUM BASH VERSION 4.2
#TODO: check this.

#Auto calculated values. Don't worry about these.
thisDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#User configured parameters
installTo="/usr/local/bin"

#Explicitly define scripts to install; avoid any unintended behavior
#scripts=("mkwp.sh" "rpass-alpha.sh")
scriptSource="${thisDir}" #instead of defining scripts, we'll define the folder.
scripts=$(ls $scriptSource | grep .*.sh) #for the daring

usage()
{
    echo "usage: ${BASH_SOURCE[0]} [source_directory] [target_directory]"
    echo ""
    echo "Installs scripts for use as if they were binaries."
    echo ""
    echo "   Arguments: "
    echo "      source_directory: subdirectory containing scripts to install"
    echo "          default is blank, yielding ${scriptSource}"
    echo "      target_directory: where to place scripts"
    echo "          default is ${installTo}"
    echo ""
    echo "   Example: ./INSTALL.sh client"
    echo "      this will install all scripts from ${scriptSource}/client \
to $installTo"
    echo ""
    exit 1
}

if [ $1 == "-h" ]; then
    usage
fi

if [ ! -z $1 ]; then
    scriptSource="${scriptSource}/${1}"
fi

if [ ! -z $2 ]; then
    installTo=$2
fi

echo "---- scripts to install ----"
for s in ${scripts[@]}; do
echo "${s}"
echo ""
read -p "Proceed? [y/n] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

for s in ${scripts[@]}; do
    if ! command -v ${s::-3} &> /dev/null; then
        echo "${s::-3} already installed, skipping"
        continue
    fi
    echo "chmod +x ${s}"
    chmod +x ${s}
    echo "ln -sv ${scriptSource}/${s} ${installTo}/${s::-3}"
    ln -sv ${scriptSource}/${s} ${installTo}/${s::-3}
    if ! command -v ${s::-3} &> /dev/null; then
        echo "FAILED!"
    else
        echo "You can now use ${s::-3}"
    fi
done
