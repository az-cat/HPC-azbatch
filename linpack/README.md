# How to run Linpack with azbatch ?

After cloning the repo, change directory to the linpack subdir and execute these steps

## Download HPL

Download the HPL binaries from our storage by running these command

    ~/HPC-azbatch/linpack$ wget "https://azcathpcsane.blob.core.windows.net/apps/hpl.tgz?sv=2017-04-17&si=read&sr=c&sig=%2BKP1aEa0ciOyckj11PxDlqoYfiXQKDhDOaJSwkbzCig%3D" -O hpl.tgz
    
    ~/HPC-azbatch/linpack$ tar xvf hpl.tgz


## Update **params.tpl**
Update the **params.tpl** file with the values specific to your environment :

* **subscription** : subscription id where your batch account is created
* **resource_group** : the resource group in which the batch account is 
* **AZURE_BATCH_ACCOUNT** : the name of the batch account
* **AZURE_BATCH_ACCESS_KEY** : batch account key
* **storage_account_name** : the storage account linked with your batch account



## Login to the Azure Batch account
When using several azure accounts you can use `az account list` to list the accounts.

    ../00-login.sh params.tpl


## Create the HPL application package


    ../01-createapppackage.sh params.tpl hpl.tpl


## Create the HPL Node Pool

    ../02-createpool.sh params.tpl ../pool-template.json


## Set the pool to use nodeprep.sh at startup

    ../03-nodeprep.sh params.tpl

## Scale your pool

    ../04-scale.sh params.tpl <nbnodes>


## Create the job. You can run this command multiple time

In the __linpack-job.tpl__ file update these values to reflect the number of nodes you want to run on :

* **hpl_MEM_GB** : This is the memory in GB used on each node. The HPL problem size will be calculated from it. 
* **hpl_P** and **hpl_P** : choose P & Q so that `PxQ = numnodes*ppn` ,
* **hpl_NB** : Block size. See the readme.txt inside the hpl package for details.

and then run


    ../05-createjob.sh params.tpl linpack-job.tpl <nbnodes>


## Monitor your job

Use [Batch Labs](https://azure.github.io/BatchLabs/) to monitor your pools and jobs. 

