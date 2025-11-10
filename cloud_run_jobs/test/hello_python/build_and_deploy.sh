

script_dir=$(dirname $0)

project_root_dir=${script_dir}/../../../

source_dir=${script_dir}
dockerfile_path=${project_root_dir}/docker-images/jobs.Dockerfile
location=europe-west2
project_id=tpx-dx-dashboards
repository_name=cloud-run-images
image_name="hello-python"

# Tag must have specific format to be able to be pushed to artifact registry
image_tag=${location}-docker.pkg.dev/${project_id}/${repository_name}/${image_name}

docker buildx build ${source_dir}  -f ${dockerfile_path} -t ${image_tag}

docker push ${image_tag}