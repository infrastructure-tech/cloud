#!/bin/bash

#MINIMUM BASH VERSION 4.2
#TODO: check this.

#Auto calculated values. Don't worry about these.
thisDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#User configured parameters
installTo="/usr/local/bin"

#Explicitly define scripts to install; avoid any unintended behavior
scripts=("mkwp.sh" "rpass-alpha.sh")
# scripts=$(ls $thisDir | grep .*.sh) #for the daring

for s in ${scripts[@]}; do
    echo "chmod +x ${s}"
    echo "ln -sv ${thisDir}/${s} ${installTo}/${s::-3}"
done