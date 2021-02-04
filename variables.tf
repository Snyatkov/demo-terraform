variable "common_tags" {
  description = "Tags for project Demo"
  type        = map(any)
  default = {
    Owner       = "Snyatkov_V"
    Environment = "Production"
    Project     = "Demo"
  }
}

variable "subnets" {
  description = "List for creation subnets int not default VPC"
  type        = list(any)
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}


variable "vpc_cidr" {
  description = "String for create not default VPC"
  default     = "10.0.0.0/16"
}

variable "site_list" {
  description = "List of site for create route to ALB"
  type        = list(any)
  default     = ["ec2.snyatkov.site", "docker.snyatkov.site", "lambda.snyatkov.site"]
}

variable "route_53_default" {
  description = "default route53 for demo site"
  default     = "Z02027932QK6EFEPPT3W2"
}

variable "DN_ssl" {
  description = "domain name for searche ssl key for https"
  default     = "*.snyatkov.site"
}

variable "instance_type" {
  description = "type of EC2 instances"
  default     = "t3.micro"
}

variable "sns_name_topic_admin_allert" {
  description = "Name of sns topic for admin allert"
  default     = "Admin_allert"
}
