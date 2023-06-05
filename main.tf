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

resource "kestra_namespace" "com_kestra" {
  namespace_id = "com.kestra"
  variables = yamlencode({
    "slack" = {
      "webhook" = "{{ secret('SLACK_WEBHOOK') }}"
    },
    "github" = {
      "token": "{{ secret('GITHUB_TOKEN') }}"
    },
    "maxmind" = {
      apiKey = "{{ secret('MAXMIND_APIKEY') }}"
    }
  })
  task_defaults = file("task-default.yml")
}

resource "kestra_flow" "flows" {
  for_each = fileset(path.module, "flows/*.yml")
  flow_id = yamldecode(templatefile(each.value, {}))["id"]
  namespace = yamldecode(templatefile(each.value, {}))["namespace"]
  content = templatefile(each.value, {})
}

resource "kestra_namespace_secret" "slack_webhook" {
  namespace = "prod"
  secret_key = "SLACK_WEBHOOK"
  secret_value = var.slack_webhook
}

resource "kestra_template" "templates" {
  for_each = fileset(path.module, "templates/*.yml")
  template_id = yamldecode(templatefile(each.value, {}))["id"]
  namespace = yamldecode(templatefile(each.value, {}))["namespace"]
  content = templatefile(each.value, {})
  depends_on = [kestra_flow.flows] # Here we ensure that the flow is deployed before the template
}