#!/usr/bin/env bash
impi_version=`ls /opt/intel/impi`
source /opt/intel/impi/${impi_version}/bin64/mpivars.sh

export I_MPI_FABRICS=shm:dapl
export I_MPI_DAPL_PROVIDER=ofa-v2-ib0
export I_MPI_DYNAMIC_CONNECTION=0
export I_MPI_FALLBACK_DEVICE=0

export PATH=/data/applications/ansys_inc/v182/fluent/bin:/opt/intel/impi/${impi_version}/bin64:$PATH

# build the hostfile required by fluentbench.pl script
IFS=',' read -r -a nodelist <<< "$AZ_BATCH_HOST_LIST"
for node in "${nodelist[@]}"
do
    echo "$node:$3" >> hostsfile
done

echo "Running Ansys Benchmark case : [$2] on $1 cores"

#printenv

fluentbench.pl $2 -t$1 -pib.dapl -mpi=intel -ssh -cnf=hostsfile

