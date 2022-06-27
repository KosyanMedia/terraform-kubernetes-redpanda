locals {
  tags = merge(
    {
      "app"                          = format("%s", var.name),
      "app.kubernetes.io/name"       = format("%s", var.name),
      "app.kubernetes.io/managed-by" = "Terraform"
    },
  var.tags)
  args = ["redpanda", "start", "--advertise-rpc-addr=$(POD_NAME).${var.name}-headless.${var.namespace}.svc.cluster.local.:33145", "--overprovisioned", "--kernel-page-cache=true", "--default-log-level=debug", "--smp=1", "--memory=1159641170", "--reserve-memory=0M"]
}
