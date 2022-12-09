#! /bin/sh

# PYTHON REWRITE THIS, THIS IS HORRIBLE

# $SERVICE_DIR is a directory with all the $SERVICE_NAME.sh files
# $SERVICE_NAME.sh is a file that defines the following variables
# $CMD, the full path to the execuatble
# $CMD_ARGS, the arguments to $CMD

# one-shots are not currently supported
# currently the stdout/stderr of the services are lost

# start(), start a service named $SERVICE_NAME.sh, the special $1 "all" starts all services
# stop(), stop a service named $SERVICE_NAME, check the $PID_DIR and remove its entry
# list(), list $SERVICE_NAME, the special $1 "all" lists all services check the $PID_DIR

SERVICE_DIR=/etc/init.d/services
PID_DIR=/etc/init.d/services_pid

if ! test -d $SERVICE_DIR; then
	mkdir -pv $SERVICE_DIR || exit
fi

# NOTE REMOVE THIS WHEN THE PROGRAM IS FUNCTIONIFIED
rm -rf $PID_DIR
if ! test -d $PID_DIR; then
	mkdir -pv $PID_DIR || exit 
fi

cd $SERVICE_DIR || exit

for s in $(ls -1); do
pwd
	# s, service file, must end in .sh and be executable (to allow easy disabling of services
	# by controlling the executable bit)
	if ! echo "$s" | grep -q '.sh$'; then
		echo "Error: $s does not end in .sh, skipping"
		continue
	fi
	if ! test -x "$s"; then
		echo "Info: $s is disabled, skipping"
		continue
	fi

	. "${SERVICE_DIR}/${s}"
	if test -z "$CMD"; then
		echo "Error: $s did not define a \$CMD variable, skipping"
		continue
	fi

	# create database entry
	pid=$(sh -c "echo $$; exec $CMD >/dev/null 2>&1")
	echo "$pid" | tee "${PID_DIR}/${s%.*}"
done
