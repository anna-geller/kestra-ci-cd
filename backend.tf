terraform {
  cloud {
    organization = "kestra-flows" # CHANGE TO YOUR ORG NAME
    hostname = "app.terraform.io"

    workspaces {
      name = "kestra-prod" # CHANGE TO YOUR WORKSPACE NAME
    }
  }
}
