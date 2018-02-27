#!/usr/bin/env bash
impi_version=`ls /opt/intel/impi`
source /opt/intel/impi/${impi_version}/bin64/mpivars.sh

hpl_dir=$AZ_BATCH_APP_PACKAGE_hpl_latest/hpl
hostlist=$AZ_BATCH_HOST_LIST

cp $hpl_dir/HPL.dat .

NUMNODES=$1
PPN=$2
HPL_MEM=$3
HPL_NB=$6
HPL_P=$4
HPL_Q=$5

NP=$(( $NUMNODES*$PPN ))

# taken from here: http://www.crc.nd.edu/~rich/CRC_Summer_Scholars_2014/HPL-HowTo.pdf
HPL_N=$(bc <<< "((sqrt(${HPL_MEM}*${NUMNODES}*1024^3/8))/${HPL_NB})*${HPL_NB}")

mpirun -np $NP -perhost $PPN -hosts $hostlist -env I_MPI_FABRICS=shm:dapl -env I_MPI_DAPL_PROVIDER=ofa-v2-ib0 -env I_MPI_DYNAMIC_CONNECTION=0 -env I_MPI_FALLBACK_DEVICE=0 $hpl_dir/xhpl_intel64_static -n $HPL_N -p $HPL_P -q $HPL_Q -nb $HPL_NB

if [ -n "$ANALYTICS_WORKSPACE" ]; then
    bash $hpl_dir/linpack_telemetry.sh ../stdout.txt $NUMNODES $PPN
    bash $hpl_dir/upload_log_analytics.sh $ANALYTICS_WORKSPACE LinpackMetrics $ANALYTICS_KEY telemetry.json
fi
