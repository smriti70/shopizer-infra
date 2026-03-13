variable "name" { type = string }
variable "image" { type = string }
variable "internal_port" { type = number }
variable "external_port" { type = number }
variable "network_name" { type = string }
variable "env_vars" {
  type    = list(string)
  default = []
}
