# How to run Fluent benchmarks cases with azbatch ?

The pre-requisites of this environment is that an NFS server exists used to store the Fluent binaries and benchmark cases. Use the **deploy_infra.json** inside the **ARM** folder to create such server. That NFS server should be in the same VNET that the compute nodes.

Before starting, update the __params.tpl__ file with the values of your environment, and especially the **pool_vnet**

## Login to the Azure Batch account

    ../00-login.sh params.tpl


## Create the Fluent Node Pool

    ../02-createpool.sh params.tpl


## Set the pool to use nodeprep.sh at startup

In the __nodeprep.sh__ script, if needed update the values of **NFS_MASTER** and **NFS_MOUNT** to match your environment, before uploading the script for the pool startup task.

    ../03-nodeprep.sh params.tpl

## Scale your pool

    ../04-scale.sh params.tpl <nbnodes>


## Submit your job. You can run this command multiple times

In the **fluentbench-job.tpl** file, update **ppn** and **case** to reflect the number of processed per nodes you want to run on, and the fluent benchmark input case name.

    ../05-createjob.sh params.tpl fluentbench-job.tpl <nbnodes>

A job named **fluentbench** will be created and a task named with the date time will be submitted.

## Monitor your job with Batch Labs

Use [Batch Labs](https://azure.github.io/BatchLabs/) to monitor your pools and jobs. 

