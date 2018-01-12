jobscript=linpack.sh
coordinationscript=linpack-coordination.sh
job_id=linpack
job_type=mpijob
numnodes=2
coordination='bash $AZ_BATCH_TASK_SHARED_DIR/'${coordinationscript}
commandline='sudo -E -u _azbatch bash $AZ_BATCH_TASK_WORKING_DIR/'${jobscript}' 4 2 69120 2 2 192'
input_dir=
