variable "name" {
  type        = string
  description = "Name of the resource"
  default     = "redpanda"
}

variable "namespace" {
  type        = string
  default     = "redpanda"
  description = "Namespace for resources"
  nullable    = false
}

variable "image" {
  type        = string
  default     = "vectorized/redpanda:latest"
  description = "Docker image of Redpanda"
  nullable    = false
}

variable "init_container_image" {
  type        = string
  default     = "vectorized/configurator:latest"
  description = "Docker image of Redpanda"
  nullable    = false
}

variable "image_pull_policy" {
  type        = string
  default     = "Always"
  description = "Docker image pull policy"
  nullable    = false
}

variable "node_selector" {
  type        = map(string)
  default     = {}
  description = "Node selector map"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "replicas" {
  type        = number
  description = "number of redpanda instances"
  default     = 3
  nullable    = false
}

variable "limits" {
  type        = map(string)
  description = "Limits for redpanda"
  default = {
    "cpu"    = "2"
    "memory" = "2Gi"
  }
  nullable = false
}

variable "requests" {
  type        = map(string)
  description = "Requests for redpanda"
  default = {
    "cpu"    = "2"
    "memory" = "2Gi"
  }
  nullable = false
}

variable "storage_size" {
  type        = string
  default     = "100G"
  description = "Size of storage"
}

variable "storage_class" {
  type        = string
  default     = "csi-gp2"
  description = "Storage class name"
}