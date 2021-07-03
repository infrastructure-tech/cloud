#!/bin/bash

# Calculated vars
thisDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Default vars
ip="0.0.0.0"
network="tinc"
port="655"
cidr="/24"
netmask="255.255.255.0"
# TODO: determine netmask automatically from cidr.

usage()
{
    echo "usage: ${BASH_SOURCE[0]} ip [network] [port] [cidr netmask]"
    echo "If you would like your hosts files automatically populated,\
 please place existing host files in ${thisDir}/network/hosts/"
    echo ""
    echo "Installs and configures tinc 1.1pre17. Prints generated conf."
    echo ""
    echo "   Arguments: "
    echo "      ip: the ip for this host (${HOSTNAME}); REQUIRED"
    echo "      network: the name of your tinc network;\
 OPTIONAL, default = ${network}"
    echo "      port: the port for tinc to use; OPTIONAL, default = ${port}"
    echo "      cidr: network cidr; OPTIONAL, default = ${cidr}"
    echo "      netmask: MUST CORRELTATE WITH CIDR;\
 OPTIONAL default = {$netmask}"
    echo ""
    echo "   Dependencies: apt"
    echo "      Everything else will be installed"
    echo ""
    echo "   Example: ./tinc-setup.sh 10.0.0.1 foo 12345 /16 255.255.0.0"
    echo "      this will use the ./foo/hosts/ folder."
    echo ""
    exit 1
}

# Prints error message and usage, then exits
# ARGUMENTS: error_message
error()
{
    echo "ERROR: $1"
    echo ""
    usage
}

#TODO: the following need type checking.

if [ $1 == "-h" ]; then
    usage
fi

if [ -z $1 ]; then
    error "Please specify an ip"
else
    ip=$1
fi

if [ ! -z $2 ]; then
    network=$2
fi

if [ ! -z $3 ]; then
    port=$3
fi

if [ ! -z $4 ]; then
    if [ ! -z $5 ]; then
        cidr=$4
        netmask=$5
    else
        error "Please specify both the netmask and cidr.\
 Yes this is dumb. We'll fix it in a future release."
    fi
fi

# Extrapolated variables
device=$network
ipCidr="${ip}${cidr}"
hosts=$(cd $thisDir/$network/hosts/ && ls)

echo "We're all set! Here's what we got:"
echo "    host = ${HOSTNAME}"
echo "    ip = ${ip}"
echo "    network = ${network}"
echo "    port = ${port}"
echo "    cidr = ${cidr}"
echo "    netmask = ${netmask}"
echo "    device = ${device}"
echo "    ipCidr = ${ipCidr}"
echo "    ---- hosts ----"
for h in ${hosts[@]}; do
echo "    ${h}"
done
echo ""
echo "Once we start, everything will be automated, except"
echo "YOU WILL HAVE TO PRESS \"ENTER\" 4 TIMES. This will be fixed later."
read -p "Continue? [y/n] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

echo "Let's go!"

echo "Making sure tinc is installed"
if ! command -v tinc &> /dev/null; then
    echo "tinc could not be found. Installing..."
    apt install -y\
 build-essential\
 libncurses5-dev\
 libreadline-dev\
 liblzo2-dev\
 libz-dev\
 libssl-dev texinfo
    
    if [ ! -d tinc-1.1pre17 ]; then
        wget https://www.tinc-vpn.org/packages/tinc-1.1pre17.tar.gz
        tar xzf tinc-1.1pre17.tar.gz
    fi
    cd tinc-1.1pre17/
    ./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var
    make
    make install
    tincd --version
    if ! command -v tinc &> /dev/null; then
        echo "Install failed."
        exit
    fi
fi


echo "Removing any conflicting files"
rm -rfv /etc/tinc/$network

# Then create directory
mkdir -p /etc/tinc/$network/hosts

echo "Creating tinc.conf"
cat << EOF >> /etc/tinc/$network/tinc.conf
Name = $HOSTNAME
AddressFamily = ipv4
Interface = $device
Mode = switch
Port = $port
AutoConnect = yes

EOF
#NOTE: that last empty line is important.

echo "Populating hosts"
for h in ${hosts[@]}; do
    cp -v $thisDir/$network/hosts/$h /etc/tinc/$network/hosts/$h
    echo "ConnectTo = ${h}" >> /etc/tinc/$network/tinc.conf
done

echo "Creating host file for $HOSTNAME"
#echo "Address =\
# `dig TXT +short o-o.myaddr.l.google.com @ns1.google.com |\
# awk -F'"' '{ print $2}'`" >> /etc/tinc/$network/hosts/$HOSTNAME
cat << EOF > /etc/tinc/$network/hosts/$HOSTNAME
Address = $(dig +short myip.opendns.com @resolver1.opendns.com)
Subnet = $ip/32
Port = $port
EOF
echo "Generating keys"
tinc -n $network generate-keys 4096

echo "Creating tinc-up"
cat << EOF > /etc/tinc/$network/tinc-up
#!/bin/sh
ip link set dev \$INTERFACE up
ip addr add $ipCidr dev \$INTERFACE
EOF

echo "Creating tinc-down"
cat << EOF > /etc/tinc/$network/tinc-down
#!/bin/sh
ip link set dev \$INTERFACE down
EOF

chmod 755 /etc/tinc/$network/tinc-*


cat << EOF > /etc/systemd/system/tinc.service
# This is a mostly empty service, but allows commands like stop, start, reload
# to propagate to all tinc@ service instances.

[Unit]
Description=Tinc VPN
Documentation=info:tinc
Documentation=man:tinc(8) man:tinc.conf(5)
Documentation=http://tinc-vpn.org/docs/
After=network.target
Wants=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/true
ExecReload=/bin/true
WorkingDirectory=/etc/tinc

[Install]
WantedBy=multi-user.target
EOF

cat << EOF > /etc/systemd/system/tinc@.service
[Unit]
Description=Tinc net %i
Documentation=info:tinc
Documentation=man:tinc(8) man:tinc.conf(5)
Documentation=http://tinc-vpn.org/docs/
PartOf=tinc.service
ReloadPropagatedFrom=tinc.service

[Service]
Type=simple
WorkingDirectory=/etc/tinc/%i
ExecStart=/usr/sbin/tincd -n %i -D
ExecReload=/usr/sbin/tinc -n %i reload
KillMode=mixed
Restart=on-failure
RestartSec=5
TimeoutStopSec=5

[Install]
WantedBy=tinc.service
EOF

systemctl daemon-reload

#makes tinc start on boot.
#COMMENT THIS OUT IF YOU DON'T WANT TINC TO AUTOSTART
#TODO: make argument option.
echo "Setting tinc to autostart"
echo $network > /etc/tinc/nets.boot
systemctl enable tinc@$network
systemctl enable tinc
echo "MAKE SURE THAT WORKED!" #TODO: did it?

echo "done."

echo "Here is our conf:"
cat /etc/tinc/$network/hosts/$HOSTNAME