
jobscript=runme.sh
coordinationscript=runme-coord.sh
job_id=runme
job_type=mpijob
numnodes=

# the coordination command line to start on all nodes part of the MPI job. This is used to synch nodes before starting
coordination='bash $AZ_BATCH_TASK_SHARED_DIR/'${coordinationscript}

# the command line to be started
commandline='sudo -E -u _azbatch bash $AZ_BATCH_TASK_WORKING_DIR/'${jobscript}' <param1> <param2> <param3>'

# input directory that contains data to be uploaded for that task
input_dir=

# the application package to use for that task if different from the pool one
task_app_package=