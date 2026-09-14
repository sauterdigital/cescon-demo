resource "google_cloudbuild_trigger" "pr_checks" {
  name            = "pr-${var.project_name}"
  project         = var.cicd_runner_project_id
  location        = var.region
  description     = "Trigger for PR checks"
  service_account = resource.google_service_account.cicd_runner_sa.id

  github {
    owner = var.repository_owner
    name  = var.repository_name
    pull_request {
      branch          = "^main$"
      comment_control = "COMMENTS_DISABLED"
    }
  }

  filename = ".cloudbuild/pr_checks.yaml"
  included_files = [
    "app/**",
    "tests/**",
    "deployment/**",
    "uv.lock",
  ]
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
  depends_on = [
    resource.google_project_service.cicd_services,
    resource.google_project_service.deploy_project_services,
  ]
}

resource "google_cloudbuild_trigger" "cd_pipeline" {
  name            = "cd-${var.project_name}"
  project         = var.cicd_runner_project_id
  location        = var.region
  service_account = resource.google_service_account.cicd_runner_sa.id
  description     = "Trigger for CD pipeline"

  github {
    owner = var.repository_owner
    name  = var.repository_name
    push {
      branch = "^main$"
    }
  }

  filename = ".cloudbuild/staging.yaml"
  included_files = [
    "app/**",
    "tests/**",
    "deployment/**",
    "uv.lock"
  ]
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
  substitutions = {
    _STAGING_PROJECT_ID          = var.staging_project_id
    _LOGS_BUCKET_NAME_STAGING    = resource.google_storage_bucket.logs_data_bucket[var.staging_project_id].name
    _APP_SERVICE_ACCOUNT_STAGING = google_service_account.app_sa["staging"].email
    _REGION                      = var.region
  }
  depends_on = [
    resource.google_project_service.cicd_services,
    resource.google_project_service.deploy_project_services,
  ]
}

resource "google_cloudbuild_trigger" "dev_pipeline" {
  name            = "dev-${var.project_name}"
  project         = var.cicd_runner_project_id
  location        = var.region
  service_account = resource.google_service_account.cicd_runner_sa.id
  description     = "Trigger for dev pipeline"

  github {
    owner = var.repository_owner
    name  = var.repository_name
    push {
      branch = "^develop$"
    }
  }

  filename = ".cloudbuild/dev.yaml"
  included_files = [
    "app/**",
    "tests/**",
    "deployment/**",
    "uv.lock"
  ]
  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"
  substitutions = {
    _DEV_PROJECT_ID          = var.dev_project_id
    _LOGS_BUCKET_NAME_DEV    = resource.google_storage_bucket.logs_data_bucket[var.dev_project_id].name
    _APP_SERVICE_ACCOUNT_DEV = google_service_account.app_sa["dev"].email
    _REGION                  = var.region
  }
  depends_on = [
    resource.google_project_service.cicd_services,
    resource.google_project_service.deploy_project_services,
  ]
}

resource "google_cloudbuild_trigger" "deploy_to_prod_pipeline" {
  name            = "deploy-${var.project_name}"
  project         = var.cicd_runner_project_id
  location        = var.region
  description     = "Trigger for deployment to production"
  service_account = resource.google_service_account.cicd_runner_sa.id

  github {
    owner = var.repository_owner
    name  = var.repository_name
    push {
      branch = "^__manual-prod-deploy-only__$"
    }
  }

  filename            = ".cloudbuild/deploy-to-prod.yaml"
  approval_config {
    approval_required = true
  }
  substitutions = {
    _PROD_PROJECT_ID          = var.prod_project_id
    _LOGS_BUCKET_NAME_PROD    = resource.google_storage_bucket.logs_data_bucket[var.prod_project_id].name
    _APP_SERVICE_ACCOUNT_PROD = google_service_account.app_sa["prod"].email
    _REGION                   = var.region
  }
  depends_on = [
    resource.google_project_service.cicd_services,
    resource.google_project_service.deploy_project_services,
  ]
}
