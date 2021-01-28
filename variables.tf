variable "common_tags" {
  type = map(any)
  default = {
    Owner       = "Snyatkov_V"
    Environment = "Production"
    Project     = "Demo"
  }
}
