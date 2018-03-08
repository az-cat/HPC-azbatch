# subscription Id to use to logon
subscription=

# resource group of the batch account
resource_group=

# batch account - if key is empty Azure AD auth will be used
AZURE_BATCH_ACCOUNT=
AZURE_BATCH_ACCESS_KEY=

# Azure VM size
vm_size=Standard_H16r 

# The image reference is in the format: {publisher}:{offer}:{sku}:{version} where {version} is
# optional and will default to 'latest'.
# see https://docs.microsoft.com/en-us/azure/virtual-machines/linux/cli-ps-findimage
# 
vm_image="OpenLogic:CentOS-HPC:7.1"

# To list supported node agent use: az batch pool node-agent-skus list
node_agent="batch.node.centos 7"

# When using a custom image use image_id and node_agent
# The custom image must be a managed image resource in the same Azure subscription and region as the Batch account
# /subscriptions/{subscription}/resourceGroups/{group}/providers/Microsoft.Compute/images/{name}}
image_id=

# pool name to create
pool_id=

# azure storage account link to the batch account
storage_account_name=

# container name to use to store input job file, bu default the pool name
container_name=$pool_id

# name of the application package to be used in your pool, leave empty for none
app_package=

# The ARM resource identifier of the virtual network subnet which the compute nodes of the pool will join
# The virtual network must be in the same region and subscription as the Azure Batch account
# /subscriptions/{subscription}/resourceGroups/{group}/providers/Microsoft.Network/virtualNetworks/{network}/subnets/{subnet}
pool_vnet=