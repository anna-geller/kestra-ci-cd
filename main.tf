terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
  required_providers {
    kestra = {
      source  = "kestra-io/kestra"
      version = "~>0.11.1"
    }
  }
}

provider "kestra" {
  url      = var.hostname # "http://localhost:8080"
  username = var.username
  password = var.password
}

resource "kestra_flow" "flows" {
  keep_original_source = true
  for_each             = fileset(path.module, "flows/*/*.yml")
  flow_id              = yamldecode(templatefile(each.value, {}))["id"]
  namespace            = yamldecode(templatefile(each.value, {}))["namespace"]
  content              = templatefile(each.value, {})
}
