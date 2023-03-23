variable "environment_suffix" {
  type = string

  description = "Description qui s'affiche lors du terraform plan pour demander la valeur de la variable"
}

variable "location" {
    type = string
    default = "West Europe"
}

variable "project_name" {
 type = string
 default = "dnce"
}

######## Merci copilot

variable "database_name" {
  type        = string
  description = "The name of the database to create"
}

variable "database_dialect" {
  type        = string
  description = "The database dialect to use"
}

variable "database_port" {
  type        = string
  description = "The database port to use"
}

variable "access_token_expiry" {
  type        = string
  description = "The access token expiry time"
}

variable "refresh_token_expiry" {
  type        = string
  description = "The refresh token expiry time"
}

variable "refresh_token_cookie_name" {
  type        = string
  description = "The refresh token cookie name"
}

variable "api_port" {
  type        = string
  description = "The port to use for the API"
}