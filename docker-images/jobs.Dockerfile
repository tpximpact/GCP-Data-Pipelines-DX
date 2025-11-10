FROM python:3.12.12-trixie

RUN pip install --upgrade pip


# We use UV for venv management.
RUN pip install uv

# Stick code in app
COPY . /app
WORKDIR "/app"

# Get a venv
RUN uv venv
# Install everything from lockfile.
RUN uv sync

# Run the code!
ENTRYPOINT ["uv", "run", "python", "-m", "src.main"]

