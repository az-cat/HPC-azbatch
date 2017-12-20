#!/usr/bin/env bash
impi_version=`ls /opt/intel/impi`
source /opt/intel/impi/${impi_version}/bin64/mpivars.sh

hpl_dir=$AZ_BATCH_APP_PACKAGE_hpl_latest/hpl
hostlist=$AZ_BATCH_HOST_LIST

cp $hpl_dir/HPL.dat .

mpirun -np $1 -perhost $2 -hosts $hostlist -env I_MPI_FABRICS=shm:dapl -env I_MPI_DAPL_PROVIDER=ofa-v2-ib0 -env I_MPI_DYNAMIC_CONNECTION=0 -env I_MPI_FALLBACK_DEVICE=0 $hpl_dir/xhpl_intel64_static -n $3 -p $4 -q $5 -nb $6

