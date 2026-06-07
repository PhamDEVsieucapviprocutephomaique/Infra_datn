resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  ="ingress-nginx"
#   version    = "4.0.6"
  create_namespace = true

  set =[
  {
    name  = "controller.service.type"
    value = "LoadBalancer"
  },

  {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    value = "true"
  },

  # Cấu hình resources cho controller
  {
    name  = "controller.resources.requests.cpu"
    value = "100m"
  },
  {
    name  = "controller.resources.requests.memory"
    value = "128Mi"
  }
  ]

    


}

data "kubernetes_service" "nginx_ingress" {
  depends_on = [helm_release.nginx_ingress]
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

# Output IP để dùng cho App Gateway
output "nginx_internal_ip" {
  value = data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].ip
  description = "Internal IP của NGINX Ingress để gán vào App Gateway backend"
}