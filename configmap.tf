resource "kubernetes_config_map" "configmap" {
  metadata {
    name      = "${var.name}-config"
    namespace = var.namespace
    labels    = local.tags
  }
  data = {
    "redpanda.yaml" = templatefile("${path.module}/templates/redpanda.yaml.tftpl", {
      name      = var.name
      namespace = var.namespace
      replicas  = range(var.replicas)
      region    = var.region
      purpose   = var.purpose
    })
  }
}