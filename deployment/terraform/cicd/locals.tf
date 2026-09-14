locals {
  cicd_services = [
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "aiplatform.googleapis.com",
    "serviceusage.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudtrace.googleapis.com",
    "telemetry.googleapis.com",
  ]

  deploy_project_services = [
    "aiplatform.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "bigquery.googleapis.com",
    "serviceusage.googleapis.com",
    "logging.googleapis.com",
    "cloudtrace.googleapis.com",
    "telemetry.googleapis.com",
  ]

  deploy_project_ids = {
    dev     = var.dev_project_id
    staging = var.staging_project_id
    prod    = var.prod_project_id
  }

  all_project_ids = [
    var.cicd_runner_project_id,
    var.dev_project_id,
    var.staging_project_id,
    var.prod_project_id
  ]
}
