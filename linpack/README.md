# How to run Linpack with azbatch ?

Before starting, update the __params.tpl__ file with the values of your environemnt, and copy the HPL binaries and dependencies into the hpl subdirectory, then run these commands

## Login to the Azure Batch account

    ../00-login.sh params.tpl


## Create the HPL application package

    ../01-createapppackage.sh params.tpl hpl.tpl


## Create the HPL Node Pool

    ../02-createpool.sh params.tpl


## Set the pool to use nodeprep.sh at startup

    ../03-nodeprep.sh params.tpl

## Scale your pool

    ../04-scale.sh params.tpl <nbnodes>


## Create the job. You can run this command multiple time

    ../05-createjob.sh params.tpl linpack-job.tpl


## Monitor your job

Use [Batch Labs](https://azure.github.io/BatchLabs/) to monitor your pools and jobs. 

