DIRECTORIES=("cloud_functions/runn/people" "cloud_functions/runn/projects")

for dir in "${DIRECTORIES[@]}"
do
    echo "Processing directory: $dir"
    cd "$dir" || { echo "Cannot enter directory $dir"; exit 1; }
    
    poetry export --without-hashes --format=requirements.txt > requirements.txt
    
    cd - > /dev/null  # Return to the previous directory
done
