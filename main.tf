terraform {
  required_providers {
    kestra = {
      source = "kestra-io/kestra" # namespace of Kestra provider
      version = "~> 0.7.0"
    }
  }
}

provider "kestra" {
  url = "https://demo.kestra.io"
  username = var.username
  password = var.password
#  jwt = "your.jwt.token"
}

resource "kestra_flow" "prod" {
  for_each = fileset(path.module, "flows/*.yml")
  flow_id = yamldecode(templatefile(each.value, {}))["id"]
  namespace = yamldecode(templatefile(each.value, {}))["namespace"]
  content = templatefile(each.value, {})
}

resource "kestra_flow" "prod_marketing" {
  for_each = fileset(path.module, "flows/marketing/*.yml")
  flow_id = yamldecode(templatefile(each.value, {}))["id"]
  namespace = yamldecode(templatefile(each.value, {}))["namespace"]
  content = templatefile(each.value, {})
}

resource "kestra_namespace_secret" "slack_webhook" {
  namespace = "prod"
  secret_key = "SLACK_WEBHOOK"
  secret_value = var.slack_webhook
}