
jobscript=runme.sh
coordinationscript=runme-coord.sh
job_id=runme
# job_type can be mpijob or basic
job_type=mpijob

#numnodes is always 1 for basic
numnodes=$1

# the coordination command line to start on all nodes part of the MPI job. This is used to synch nodes before starting
coordination='bash $AZ_BATCH_TASK_SHARED_DIR/'${coordinationscript}

# the command line to be started
# for Linux use
commandline='bash $AZ_BATCH_TASK_WORKING_DIR/'${jobscript}' <param1> <param2> <param3>'
# for Windows use
#commandline='cmd /c %AZ_BATCH_TASK_WORKING_DIR%\'${jobscript}' <param1> <param2> <param3>'

# input directory that contains data to be uploaded for that task
input_dir=

# the application package to use for that task if different from the pool one
task_app_package=

# job specific environment variables
# format is '[{"name":"variable1", "value":"value1"},{"name":"variable2", "value":"value2"}]'
jobenvsettings='[]'