#!/bin/bash

LEN=128
if [ ! -z $1 ]; then
    LEN=$1
fi


</dev/urandom tr -dc 'A-Za-z0-9' | head -c $LEN  ; echo
