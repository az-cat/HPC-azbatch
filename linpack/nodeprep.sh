#!/bin/bash
set -e
yum -y install epel-release
yum -y install jq

# Disable requiretty to allow run sudo within scripts
sed -i -e 's/Defaults    requiretty.*/ #Defaults    requiretty/g' /etc/sudoers

