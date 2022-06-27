resource "kubernetes_service_account" "sa" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = var.tags
  }
}

resource "kubernetes_secret" "secret" {
  type = "kubernetes.io/service-account-token"
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = var.tags
    annotations = {
      "kubernetes.io/service-account.name" = "${var.name}"
    }
  }

}

resource "kubernetes_stateful_set" "stateful_set" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = local.tags
  }

  spec {
    replicas     = var.replicas
    service_name = "${var.name}-headless"
    selector {
      match_labels = local.tags
    }

    template {
      metadata {
        labels = local.tags
        annotations = {
          "prometheus.io/port"   = "9644"
          "prometheus.io/scrape" = "true"
        }
        name = var.name
      }
      spec {
        service_account_name = var.name

        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              pod_affinity_term {
                label_selector {
                  match_labels = local.tags
                }
                namespaces   = [var.namespace]
                topology_key = "kubernetes.io/hostname"
              }
              weight = 100
            }
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_labels = var.tags
              }
              namespaces   = [var.namespace]
              topology_key = "kubernetes.io/hostname"
            }
          }
        }

        image_pull_secrets {
          name = "dockerhub"
        }
        node_selector = var.node_selector

        container {
          name              = var.name
          image             = var.image
          image_pull_policy = var.image_pull_policy
          command           = ["/usr/bin/rpk"]
          args              = local.args

          env {
            name  = "REDPANDA_ENVIRONMENT"
            value = "kubernetes"
          }

          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "metadata.name"
              }
            }
          }

          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "metadata.namespace"
              }
            }
          }

          env {
            name = "POD_IP"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "status.podIP"
              }
            }
          }

          port {
            container_port = 33145
            name           = "rpc"
          }
          port {
            container_port = 9644
            name           = "admin"
          }
          port {
            container_port = 9092
            name           = "kafka"
          }
          port {
            container_port = 8082
            name           = "proxy"
          }

          resources {
            limits   = var.limits
            requests = var.requests
          }

          volume_mount {
            mount_path = "/etc/redpanda"
            name       = "config-dir"
          }
          volume_mount {
            mount_path = "/var/lib/redpanda/data"
            name       = "datadir"
            read_only  = false
          }
        }
        init_container {
          name              = "${var.name}-init"
          image             = var.init_container_image
          image_pull_policy = var.image_pull_policy
          security_context {
            run_as_group = 101
            run_as_user  = 101
          }

          env {
            name  = "SERVICE_FQDN"
            value = "${var.name}.${var.namespace}.svc.cluster.local."
          }

          env {
            name  = "CONFIG_SOURCE_DIR"
            value = "/mnt/operator"
          }

          env {
            name  = "CONFIG_DESTINATION"
            value = "/etc/redpanda/redpanda.yaml"
          }

          env {
            name  = "REDPANDA_RPC_PORT"
            value = "33145"
          }

          env {
            name = "EXTERNAL_CONNECTIVITY_SUBDOMAIN"
          }

          env {
            name  = "EXTERNAL_CONNECTIVITY"
            value = false
          }

          env {
            name = "HOST_PORT"
          }

          env {
            name = "NODE_NAME"
            value_from {
              field_ref {
                api_version = "v1"
                field_path  = "spec.nodeName"
              }
            }
          }

          volume_mount {
            mount_path = "/etc/redpanda"
            name       = "config-dir"
          }

          volume_mount {
            mount_path = "/mnt/operator"
            name       = "configmap-dir"
          }

        }
        volume {
          name = "datadir"
          persistent_volume_claim {
            claim_name = "datadir"
          }
        }
        volume {
          empty_dir {}
          name = "config-dir"
        }

        volume {
          config_map {
            default_mode = "0766"
            name         = "${var.name}-config"
          }
          name = "configmap-dir"
        }
        security_context {
          fs_group = 101
        }
      }
    }
    volume_claim_template {
      metadata {
        labels    = local.tags
        name      = "datadir"
        namespace = var.namespace
      }
      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = var.storage_class
        resources {
          requests = {
            "storage" = var.storage_size
          }
        }
      }
    }
  }
  depends_on = [
    kubernetes_config_map.configmap,
    kubernetes_service_account.sa,
    kubernetes_service.redpanda_service_headless
  ]
}
