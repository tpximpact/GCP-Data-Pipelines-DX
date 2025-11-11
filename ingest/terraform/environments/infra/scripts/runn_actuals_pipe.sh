region="europe-west2"
project="tpx-dx-dashboards"
tasks=1
retries=0
timeout="3h"
service_account="tpx-dx-dashboards@appspot.gserviceaccount.com"

do_create() {
	pwd
	source_dir=$(realpath $1)
	gcloud run jobs deploy runn-actuals-pipe \
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
	gcloud run jobs delete runn-actuals-pipe \
		--region $region \
		--project $project \
		--quiet
}


case $1 in

	"create")
		do_create $2
	;;


	"destroy")
		do_destroy
	;;	
esac


