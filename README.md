# azbatch
CLI recipes and scripts to easily run MPI applications with Azure Batch.

Pererequisite is to have an Azure Batch account (Batch Service) and a storage account linked to it. Make sure to have enough quota for the VMs you want to use in your region.

# Quickstart

1. Open a Linux session with Azure CLI v2.0, jq and zip packages installed.

2. Clone the repository, `git clone https://github.com/az-cat/HPC-azbatch.git`

3. Grant execute access to scripts `chmod +x *.sh`


## Build your own jobs 


## Run the samples

* [Linpack](./linpack/README.md)
* [Ansys Fluent](./fluent/README.md)

## Quickly add an NFS server

If you need an NFS server which can also be used as a jumpbox, the companion ARM template file [here](./ARM/deploy_infra.json) will create :

* A 10.0.0.0/20 VNET with two subnets

    * admin subnet on 10.0.0.1/28
    * compute subnet on 10.0.2.0/23

* A Standard_D8s_v3 VM, running CentOS 7.4, named **nfsnode**
* A public IP to connect to that VM
* 1 TB of attached premium disk (P30)
* NSG rules

    * Open SSH on the public IP
    * Deny internet incoming communication


Before starting make sure you have enough quota for DS_v3 in the region you want to deploy. The button below will kickoff the deployment and you will need to provide these parameters :

* Name of the vnet to create
* Name of the admin user (default being hpcadmin)
* The public RSA key to use


  [![Click to deploy template on Azure](http://azuredeploy.net/deploybutton.png "Click to deploy template on Azure")](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Faz-cat%2FHPC-azbatch%2Fmaster%2FARM%2Fdeploy_infra.json) 


