variable "api_gateway_deployment_stage" {
  description = "The name of the stage to deploy for the API Gateway which will form part of the invocation URL."
  default = "dev"
}

variable "aws_profile" {
  description = "The name of the profile to use to connect to AWS as defined in ~/.aws/credentials."
  default = "default"
}

variable "aws_region" {
  description = "The AWS region to deploy the resources into."
  default = "eu-west-1"
}

variable "cloudwatch_log_retention_in_days" {
  description = "The amount of time (in days) that the CloudWatch Logs for the Lambda function should be retained."
  default = "14"
}

variable "elasticache_engine_version" {
  description = "The desired ElastiCache Redis engine version."
  default = "3.2.4"
}

variable "elasticache_node_type" {
  description = "The instance type to use for the cache nodes in the ElastiCache cluster."
  default = "cache.m3.medium"
}

variable "elasticache_num_cache_nodes" {
  description = "The number of cache nodes to create in the ElastiCache cluster."
  default = 1
}

variable "elasticache_parameter_group_name" {
  description = "The name of a pre-existing ElastiCache parameter group to use for the ElastiCache cluster."
  default = "default.redis3.2"
}

variable "elasticache_port" {
  description = "The port number on which the ElastiCache cache nodes should listen."
  default = 6379
}

variable "project_name" {
  description = "The name for the project which is used for various elements of resource naming."
  default = "csmurton-urlinfo"
}
