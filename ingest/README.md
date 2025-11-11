# GCP Data Pipelines DX

This repository hosts a collection of Python data pipelines that ingest information from operational SaaS platforms (Runn, HubSpot, Harvest, HiBob, Pipedrive, and more) into Google Cloud. Pipelines are now packaged as [Cloud Run jobs](https://cloud.google.com/run/docs/jobs) backed by the [`uv`](https://github.com/astral-sh/uv) Python toolchain and deployed with Terraform.

> **Heads up:** legacy Cloud Functions have been migrated into the `cloud_run_jobs/` tree. Each job ships with an isolated `pyproject.toml`, lock file, and lightweight README that documents how to work with the pipeline locally.

## Repository layout

```
cloud_run_jobs/
  hubspot/
    companies/
    deals/
    deals_stages/
    pipelines/
  runn/
    assignments/
    clients/
    contracts/
    people/
    projects/
    public_holidays/
    rate_cards/
    roles/
    teams/
data_pipeline_tools/
  *.py                 # shared helpers imported by the jobs
terraform/
  environments/infra/  # Cloud Run jobs, Cloud Scheduler, Artifact Registry, etc.
docker-images/
  jobs.Dockerfile      # base image used for all Cloud Run jobs
```

Every job directory under `cloud_run_jobs/*/*` contains:

- `.dockerignore` for keeping the .venv and **pycache** entries out of docker (They have symlinks to host dirs)
- `.python-version`For pinning python version. (Currently 3.12)
- `.env.example` Copy this to .env and fill it in to run locally.
- `pyproject.toml` and `uv.lock` describing runtime dependencies
- `src/main.py` with the scheduled ingestion entrypoint
- (Optional) `src/run.py` helper for ad-hoc local runs; present today on the Runn jobs

## Prerequisites

- Python 3.12
- [`uv`](https://docs.astral.sh/uv/getting-started/installation/) 0.4 or newer
- Terraform 1.5+
- Docker (required for container builds and Terraform image packaging)
- Access to the `tpx-dx-dashboards` GCP project and related secrets

## Working on a job locally

1. Pick the job you want to run, for example `cloud_run_jobs/runn/assignments`.
2. Copy `.env.example` to `.env` and fill in the required secrets (e.g. `RUNN_API_TOKEN`).
3. Install dependencies with uv:

   ```bash
   uv sync
   ```

4. Execute the pipeline locally:

   ```bash
   uv run python -m src.main
   ```

or, for quick API smoke tests that print the first page (when the job provides `src/run.py`):

```bash
uv run python -m src.run
```

5. To keep dependencies in sync across environments, commit both `pyproject.toml` and `uv.lock` when they change.

## Deploying to Cloud Run

Terraform configuration for Cloud Run jobs lives in:

- `terraform/environments/infra/jobs_runn.tf` — Runn pipelines
- `terraform/environments/infra/jobs_hubspot.tf` — HubSpot pipelines

Each file provisions:

- Cloud Run jobs (one per pipeline) that run `uv run python -m src.main`
- Docker image builds in Artifact Registry
- Cloud Scheduler triggers that fire the jobs nightly at 03:00 (Europe/London)

To deploy new code or configuration changes:

0. Ensure you have stored some application-default credentials for terraform: See https://docs.cloud.google.com/docs/terraform/authentication
1. Ensure dockerd is running (Terraform builds images locally).
2. From `terraform/environments/infra` initialise and plan:

   ```bash
   terraform init
   terraform plan
   ```

3. Apply when ready:

   ```bash
   terraform apply
   ```

> **Note:** `terraform fmt` is recommended before opening a PR. If the Terraform CLI is unavailable in your shell, install it from <https://developer.hashicorp.com/terraform/downloads> or use `gcloud components install terraform-tools` inside Cloud Shell.

## Shared tooling

- `data_pipeline_tools/` exposes authentication helpers, BigQuery utilities, and Runn API helpers shared by all jobs. NOTE: This is
- `docker-images/jobs.Dockerfile` defines the base image used by Terraform builds. It installs Python 3.12, uv, and copies each job into `/app`.

## Conventions

- Always prefer `uv sync` over manually managing virtual environments.
- Secrets are retrieved inside the jobs via `access_secret_version` at runtime. Never commit real tokens—use `.env` locally and use Secret Manager in production.
- When adding a new pipeline, follow the pattern established in the existing jobs: scaffold with uv, create `src/main.py` (and optionally `src/run.py` for testing), then wire up Terraform.

## Further reading

- [Cloud Run jobs documentation](https://cloud.google.com/run/docs/jobs)
- [uv user guide](https://docs.astral.sh/uv/)
- [Terraform Google provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- Access to GCP
