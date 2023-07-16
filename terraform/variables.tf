# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

variable "profile" {
  description = "AWS profile"
  type        = string
  default     = "EKS"
}

