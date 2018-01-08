#! /bin/bash
# Disable requiretty to allow run sudo within scripts
sed -i -e 's/Defaults    requiretty.*/ #Defaults    requiretty/g' /etc/sudoers

yum -y install epel-release
yum -y install nfs-utils

# create a share for applications
#mkdir -p /mnt/resource/apps
#cat << EOF >> /etc/exports
#/mnt/resource/apps $localip.*(rw,sync,no_root_squash,no_all_squash)
#EOF

systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap

systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap

systemctl restart nfs-server

#exportfs -a
