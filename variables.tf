variable "location" {
  default = "West Europe"
}

variable "tags" {
  type = map(string)
  default = { 
    owner = "***REMOVED***"
    }
}

variable "resource_group_name" {
  default = "covtracker"
}