variable "username" {
    description = "User name of the Kestra instance"
    type        = string
}

variable "password" {
    description = "Password of the Kestra instance"
    type        = string
}

variable "slack_webhook" {
    description = "Slack Incoming Webhook"
    type        = string
}