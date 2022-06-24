resource "kubernetes_service" "redpanda_service" {
  metadata {
    labels      = local.tags
    name        = var.name
    namespace   = var.namespace
    annotations = {}
  }
  spec {
    external_ips                = []
    load_balancer_source_ranges = []
    selector                    = local.tags
    type                        = "ClusterIP"

    port {
      port        = 33145
      name        = "internal-rpc"
      protocol    = "TCP"
      target_port = 33145
    }
    port {
      port        = 9092
      name        = "kafka-api"
      protocol    = "TCP"
      target_port = 9092
    }
    port {
      port        = 8082
      name        = "pandaproxy"
      protocol    = "TCP"
      target_port = 8082
    }
    port {
      port        = 8081
      name        = "schema-registry"
      protocol    = "TCP"
      target_port = 8081
    }
    port {
      port        = 9644
      name        = "prometheus"
      protocol    = "TCP"
      target_port = 9644
    }

  }
  depends_on = [
    kubernetes_service_account.sa
  ]
}

resource "kubernetes_service" "redpanda_service_headless" {
  metadata {
    labels      = local.tags
    name        = "${var.name}-headless"
    namespace   = var.namespace
    annotations = {}
  }
  spec {
    external_ips                = []
    load_balancer_source_ranges = []
    selector                    = local.tags
    type                        = "ClusterIP"
    cluster_ip                  = "None"

    port {
      port        = 33145
      name        = "internal-rpc"
      protocol    = "TCP"
      target_port = 33145
    }
    port {
      port        = 9092
      name        = "kafka-api"
      protocol    = "TCP"
      target_port = 9092
    }
    port {
      port        = 8082
      name        = "pandaproxy"
      protocol    = "TCP"
      target_port = 8082
    }
    port {
      port        = 8081
      name        = "schema-registry"
      protocol    = "TCP"
      target_port = 8081
    }
    port {
      port        = 9644
      name        = "prometheus"
      protocol    = "TCP"
      target_port = 9644
    }

  }
  depends_on = [
    kubernetes_service_account.sa
  ]
}