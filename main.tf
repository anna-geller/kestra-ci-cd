terraform {
  required_providers {
    kestra = {
      source  = "kestra-io/kestra" # namespace of Kestra provider
      version = "~> 0.7.0"
    }
  }
}

provider "kestra" {
  url      = var.hostname
  username = var.username
  password = var.password
}

resource "kestra_namespace" "prod" {
  count         = var.env == "prod" ? 1 : 0
  namespace_id  = var.env
  task_defaults = file("taskDefaults.yml")
}

resource "kestra_namespace_secret" "slack_webhook" {
  count        = var.env == "prod" ? 1 : 0
  namespace    = "prod"
  secret_key   = "SLACK_WEBHOOK"
  secret_value = var.slack_webhook
}

resource "kestra_namespace_secret" "gcp_project_id" {
  count        = var.env == "prod" ? 1 : 0
  namespace    = "prod"
  secret_key   = "GCP_PROJECT_ID"
  secret_value = var.gcp_project_id
}

resource "kestra_namespace_secret" "gcp_service_account" {
  count        = var.env == "prod" ? 1 : 0
  namespace    = "prod"
  secret_key   = "GCP_SERVICE_ACCOUNT"
  secret_value = var.gcp_project_id
}

resource "kestra_flow" "flows" {
  for_each  = fileset(path.module, "flows/*.yml")
  flow_id   = yamldecode(templatefile(each.value, {}))["id"]
  namespace = yamldecode(templatefile(each.value, {}))["namespace"]
  content   = templatefile(each.value, {})
}

resource "kestra_template" "templates" {
  for_each    = fileset(path.module, "templates/*.yml")
  template_id = yamldecode(templatefile(each.value, {}))["id"]
  namespace   = yamldecode(templatefile(each.value, {}))["namespace"]
  content     = templatefile(each.value, {})
  depends_on  = [kestra_flow.flows] # Here we ensure that the flow is deployed before the template
}