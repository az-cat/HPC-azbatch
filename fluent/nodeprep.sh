#!/bin/bash
set -e
yum -y install epel-release

# Disable requiretty to allow run sudo within scripts
sed -i -e 's/Defaults    requiretty.*/ #Defaults    requiretty/g' /etc/sudoers

NFS_MASTER=10.0.1.4
NFS_MOUNT=/data

function setup_nfs
{
        # install NFS
        yum -y install nfs-utils

        mkdir -p $NFS_MOUNT

# create a share for applications
cat << EOF >> /etc/fstab
$NFS_MASTER:$NFS_MOUNT    $NFS_MOUNT   nfs defaults 0 0
EOF

        mount -a
}

# We have to change the hostname so it will be shorter than the one set by Azure Batch whihc breaks the FlexLM licence checking part of Fluent
function sethostname
{
        # change the hostname, use the IP to name it in hexa like 0A000004
        IP=`ifconfig eth0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
        W1=$(echo $IP | awk -F"." '{print $1}')
        W1=$(printf '%02x' $W1)
        W2=$(echo $IP | awk -F"." '{print $2}')
        W2=$(printf '%02x' $W2)
        W3=$(echo $IP | awk -F"." '{print $3}')
        W3=$(printf '%02x' $W3)
        W4=$(echo $IP | awk -F"." '{print $4}')
        W4=$(printf '%02x' $W4)

        newname='IP'$W1$W2$W3$W4
        hostname $newname
        hostname
}

sethostname
setup_nfs

# install Fluent dependencies
yum -y install fontconfig freetype freetype-devel fontconfig-devel libstdc++ libXext libXt libXrender-devel.x86_64 libXrender.x86_64 mesa-libGL.x86_64

