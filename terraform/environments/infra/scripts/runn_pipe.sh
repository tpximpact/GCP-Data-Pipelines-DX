region="europe-west2"
project="tpx-dx-dashboards"
tasks=1
retries=0
timeout="3h"
service_account="tpx-dx-dashboards@appspot.gserviceaccount.com"

do_create() {
	pwd
	source_dir=$(realpath $1)
	gcloud run jobs deploy $2 \
		--source $source_dir \
		--tasks $tasks \
		--task-timeout $timeout \
		--region $region \
		--project $project \
		--service-account $service_account \
		--max-retries $retries \
		--quiet
}


do_destroy() {
	gcloud run jobs delete $1 \
		--region $region \
		--project $project \
		--quiet
}


case $1 in

	"create")
		if [ "$#" -ne 3 ]; then
			echo "Usage: ./runn_pipe.sh create <dir> <job_name>"
			exit 1
		fi
		do_create $2 $3
	;;


	"destroy")
		if [ "$#" -ne 2]; then
			echo "Usage: ./runn_pipe.sh destroy <job_name>"
			exit 1
		fi
		do_destroy $2
	;;	

	# *)
	# 	echo "Usage: ./runn_pipe.sh <create|destroy> ..."
	# 	exit 1
	# ;;

esac


case $2 in

	"create")
		if [ "$#" -ne 3 ]; then
			echo "Usage: ./runn_pipe.sh create <dir> <job_name>"
			exit 1
		fi
		do_create $1 $3
	;;


	"destroy")
		if [ "$#" -ne 2]; then
			echo "Usage: ./runn_pipe.sh destroy <job_name>"
			exit 1
		fi
		do_destroy $1
	;;	
	
	# *)
	# 	echo "Usage: ./runn_pipe.sh <create|destroy> ..."
	# 	exit 1
	# ;;

esac


