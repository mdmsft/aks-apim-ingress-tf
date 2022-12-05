
locals {
  chart_namespace = "ingress-nginx"
  secret_name     = "tls"
}

resource "helm_release" "nginx" {
  name            = "ingress-nginx"
  repository      = "https://kubernetes.github.io/ingress-nginx"
  chart           = "ingress-nginx"
  namespace       = local.chart_namespace
  cleanup_on_fail = true
  atomic          = true
  wait            = true

  values = [
    templatefile("./k8s/nginx.values.yaml", {
      load_balancer_ip        = local.load_balancer_ip_address,
      load_balancer_subnet    = azurerm_subnet.cluster.name
      default_ssl_certificate = "${local.chart_namespace}/${local.secret_name}"
    })
  ]

  depends_on = [
    azurerm_role_assignment.kubernetes_service_rbac_cluster_administrator,
    kubernetes_secret_v1.tls,
    kubernetes_namespace_v1.nginx,
    local_file.kube_config
  ]
}

resource "kubernetes_namespace_v1" "nginx" {
  metadata {
    name = local.chart_namespace
  }
}

resource "kubernetes_secret_v1" "tls" {
  metadata {
    name      = local.secret_name
    namespace = local.chart_namespace
  }

  data = {
    "tls.crt" = data.azurerm_key_vault_certificate_data.ssl.pem
    "tls.key" = data.azurerm_key_vault_certificate_data.ssl.key
  }

  type = "kubernetes.io/tls"

  depends_on = [
    azurerm_role_assignment.kubernetes_service_rbac_cluster_administrator,
    local_file.kube_config,
    kubernetes_namespace_v1.nginx
  ]
}
