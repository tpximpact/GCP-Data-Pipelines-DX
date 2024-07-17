#DIRECTORIES=("cloud_functions/runn/people" "cloud_functions/runn/projects")

DIRECTORIES=(
"cloud_functions/forecast/assignments"
"cloud_functions/forecast/assignments_filled"
"cloud_functions/forecast/people"
"cloud_functions/forecast/placeholders"
"cloud_functions/forecast/projects"
"cloud_functions/harvest/clients"
"cloud_functions/harvest/expenses"
"cloud_functions/harvest/projects"
"cloud_functions/harvest/timesheet"
"cloud_functions/harvest/user_project_assignments"
"cloud_functions/harvest/users"
"cloud_functions/helpers/months_columns"
"cloud_functions/hibob/time_off"
"cloud_functions/pipedrive/deals"
"cloud_functions/pipedrive/organisations"
"cloud_functions/runn/actuals"
"cloud_functions/runn/assignments"
"cloud_functions/runn/people"
"cloud_functions/runn/projects"
"cloud_functions/runn/roles"
"cloud_functions/runn/teams"
)

for dir in "${DIRECTORIES[@]}"
do
    echo "Processing directory: $dir"
    cd "$dir" || { echo "Cannot enter directory $dir"; exit 1; }

#    poetry install
    poetry export --without-hashes --format=requirements.txt > requirements.txt

    cd /data-pipelines  # Return to the previous directory
done
