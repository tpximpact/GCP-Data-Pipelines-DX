poetry init // add all 

poetry install

poetry run python main.py

poetry export --format=requirements.txt --output=requirements.txt --without-hashes

