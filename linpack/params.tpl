# subscription Id to use to logon
subscription=

# resource group of the batch account
resource_group=

# batch account - if key is empty Azure AD auth will be used
AZURE_BATCH_ACCOUNT=
AZURE_BATCH_ACCESS_KEY=

# Azure VM size
vm_size=Standard_H16r 

# max task per node. 1 for MPI. number of cores for embarassingly parrallel tasks
taskpernode=1

# The image reference is in the format: {publisher}:{offer}:{sku}:{version} where {version} is
# optional and will default to 'latest'.
vm_image="OpenLogic:CentOS-HPC:7.1"
node_agent="batch.node.centos 7"

# pool name to create
pool_id=linpack

# azure storage account link to the batch account
storage_account_name=

# container name to use to store input job file, bu default the pool name
container_name=$pool_id

# name of the application package to be used in your pool, leave empty for none
app_package=hpl