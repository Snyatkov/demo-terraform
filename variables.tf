variable "common_tags" {
  type = map(any)
  default = {
    Owner       = "Snyatkov_V"
    Environment = "Production"
    Project     = "Demo"
  }
}

variable "subnets" {
  type    = list(any)
  default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}
