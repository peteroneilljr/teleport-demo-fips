# ---------------------------------------------------------------------------- #
# AWS Vars
# ---------------------------------------------------------------------------- #
variable "aws_vpc_cidr" {
  description = "value"
  type        = string
  default     = "10.10.0.0/16"
}
# ---------------------------------------------------------------------------- #
# AWS Gov Provider
# ---------------------------------------------------------------------------- #
variable "aws_gov_region" {
  description = "value"
  type        = string
}
variable "aws_gov_access_key" {
  description = "value"
  type        = string
  default     = null
}
variable "aws_gov_secret_key" {
  description = "value"
  type        = string
  default     = null
}
variable "aws_gov_session_token" {
  description = "value"
  type        = string
  default     = null
}
variable "aws_gov_tags" {
  description = "value"
  type        = map(any)
  default     = {}
}
# ---------------------------------------------------------------------------- #
# AWS DNS Provider
# ---------------------------------------------------------------------------- #
variable "aws_dns_region" {
  description = "value"
  type        = string
}
variable "aws_dns_route53_zone" {
  description = "value"
  type        = string
}
variable "aws_dns_access_key" {
  description = "value"
  type        = string
  default     = null
}
variable "aws_dns_secret_key" {
  description = "value"
  type        = string
  default     = null
}
variable "aws_dns_session_token" {
  description = "value"
  type        = string
  default     = null
}
variable "aws_dns_tags" {
  description = "value"
  type        = map(any)
  default     = {}
}
# ---------------------------------------------------------------------------- #
# Teleport Vars
# ---------------------------------------------------------------------------- #
variable "teleport_cluster_name" {
  description = "value"
  type        = string
}
variable "teleport_version" {
  description = "value"
  type        = string
}
variable "teleport_email" {
  description = "value"
  type        = string
}

# ---------------------------------------------------------------------------- #
# GitHub SSO Variables
# ---------------------------------------------------------------------------- #
variable "gh_client_secret" {
  description = "value"
  type        = string
}
variable "gh_client_id" {
  description = "value"
  type        = string
}
variable "gh_org_name" {
  description = "value"
  type        = string
}
variable "gh_team_name" {
  description = "value"
  type        = string
}
