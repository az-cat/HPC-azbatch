jobscript=fluentbench.sh
coordinationscript=coord-fluent.sh
job_id=fluentbench
job_type=mpijob
# number of nodes to run the job on
numnodes=$1
# number of processes per nodes
ppn=16
numcores=$(bc <<< "$numnodes * $ppn")
coordination='bash $AZ_BATCH_TASK_SHARED_DIR/'${coordinationscript}

# fluent cases for example one of these : aircraft_wing_14m, f1_racecar_140m, combustor_71m, sedan_4m
case=aircraft_wing_14m

launcher='$AZ_BATCH_TASK_WORKING_DIR/'${jobscript}' '${numcores}' '${case}' '${ppn}
commandline='bash -c "'${launcher}'"'

# input directory that contains data to be uploaded for that task
input_dir=

# the application package to use for that task if different from the pool one
task_app_package=

# job specific environment variables
# format is '[{"name":"variable1", "value":"value1"},{"name":"variable2", "value":"value2"}]'
jobenvsettings='[]'

echo $launcher
echo $commandline
