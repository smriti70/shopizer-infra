variable "username" {
  description = "macOS username for Colima socket path"
  default     = "smritisingh"
}

variable "backend_host" {
  description = "Host IP accessible from frontend containers"
  default     = "192.168.29.34"
}

variable "backend_image" {
  default = "smriti70/shopizer-backend:latest"
}

variable "admin_image" {
  default = "smriti70/shopizer-admin:latest"
}

variable "shop_image" {
  default = "smriti70/shopizer-shop:latest"
}
