terraform {
  # backend "s3" {
  #   bucket = "kestra-product-de"
  #   key    = "terraform.tfstate"
  #   region = "eu-central-1"
  # }
  required_providers {
    kestra = {
      source  = "kestra-io/kestra"
      version = "~>0.17"
    }
  }
}

provider "kestra" {
  url      = var.hostname # "http://localhost:8080"
  username = var.username
  api_token = var.api_token
  tenant_id = var.tenant_id
}

resource "kestra_flow" "flows" {
  for_each             = fileset(path.module, "flows/*/*.yml")
  flow_id              = yamldecode(templatefile(each.value, {}))["id"]
  namespace            = yamldecode(templatefile(each.value, {}))["namespace"]
  content              = templatefile(each.value, {})
}


resource "kestra_namespace" "kestra" {
  namespace_id  = "myrootnamespace"
  description   = "Friendly description"
}

resource "kestra_namespace" "kestra_analytics" {
  namespace_id  = "myrootnamespace.analytics"
  description   = "Friendly description"
}

resource "kestra_namespace_file" "prod_scripts" {
  for_each  = fileset(path.module, "scripts/**")
  namespace = kestra_namespace.kestra.namespace_id
  filename = "/${each.value}"
  content   = file(each.value)
}

resource "kestra_namespace_file" "dbt" {
  for_each  = fileset(path.module, "dbt/**")
  namespace = kestra_namespace.kestra_analytics.namespace_id
  filename = "/${each.value}"
  content   = file(each.value)
}