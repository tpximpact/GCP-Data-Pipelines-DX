poetry init
poetry install
poetry add setuptools 
poetry add hubspot-api-client
poetry export --format=requirements.txt --output=requirements.txt --without-hashes