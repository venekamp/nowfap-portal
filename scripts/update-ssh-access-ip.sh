#!/bin/bash

HOST_FILE=$1

if [[ $# < 1 ]]; then
    echo "useage: $0 <file name>"
    exit 1
fi

if [[ ! -e $HOST_FILE ]]; then
    echo "File '$HOST_FILE' not found."
    exit 1
fi

IP_ADDRESS=$(VBoxManage guestproperty get ssh-access "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{ print $2 }')

echo "Current IP address for ssh-access VM: $IP_ADDRESS"

TMP_FILE=$(mktemp "$1-XXXXXXXX")

#sed '/\[ssh-access\]/N;s/[0-9]+.[0-9]+.[0-9]+.[0-9]+\(.*\)/bla\1/' $1
sed -E "/\ssh-access\]/{N;s/[0-9]+(\.[0-9]+){1,3}/$IP_ADDRESS/;}" $HOST_FILE > $TMP_FILE

mv $TMP_FILE $HOST_FILE
