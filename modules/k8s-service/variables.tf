variable "name" { type = string }
variable "image" { type = string }
variable "container_port" { type = number }
variable "node_port" { type = number }
variable "replicas" {
  type    = number
  default = 2
}
variable "env_vars" {
  type    = map(string)
  default = {}
}
