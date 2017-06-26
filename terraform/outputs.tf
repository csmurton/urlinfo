output "urlinfo_elasticache_cluster_address" {
  value = "${aws_elasticache_cluster.urlinfo_cluster.cache_nodes.0.address}"
}

output "urlinfo_api_invoke_url" {
  value = "${aws_api_gateway_deployment.urlinfo.invoke_url}"
}

