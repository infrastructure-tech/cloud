sudo apt-get update
sudo apt-get install curl gcc memcached rsync sqlite3 xfsprogs \
                     git-core libffi-dev python-setuptools \
                     liberasurecode-dev libssl-dev
sudo apt-get install python-coverage python-dev python-nose \
                     python-xattr python-eventlet \
                     python-greenlet python-pastedeploy \
                     python-netifaces python-pip python-dnspython \
                     python-mock


sudo mkdir -p /srv
sudo truncate -s 1500GB /srv/swift-disk
sudo mkfs.xfs /srv/swift-disk


mkdir /mnt/srv
echo '/srv/swift-disk /mnt/srv xfs loop,noatime 0 0' >> /etc/fstab

sudo useradd -d /home/swift -m swift -p jMm42afVwhbm8Die4gwRSvqkGQUv2HDO
sudo mkdir /mnt/srv/1 /mnt/srv/2 /mnt/srv/3 /mnt/srv/4
sudo chown swift:swift /mnt/srv/*
for x in {1..4}; do sudo ln -s /mnt/srv/$x /srv/$x; done
sudo mkdir -p /srv/1/node/srv /srv/1/node/srv5 \
              /srv/2/node/srv2 /srv/2/node/srv6 \
              /srv/3/node/srv3 /srv/3/node/srv7 \
              /srv/4/node/srv4 /srv/4/node/srv8
sudo mkdir -p /var/run/swift
sudo mkdir -p /var/cache/swift /var/cache/swift2 \
              /var/cache/swift3 /var/cache/swift4
sudo chown -R swift:swift /var/run/swift
sudo chown -R swift:swift /var/cache/swift*

for x in {1..4}; do sudo chown -R swift:swift /srv/$x/; done

