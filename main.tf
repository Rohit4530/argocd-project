provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "5.46.8" # You can check latest on Artifact Hub

  create_namespace = true

  values = [
    file("values.yaml")
  ]
}
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  namespace  = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  create_namespace = true

  values = [
    yamlencode({
      controller = {
        extraArgs = {
          "enable-ssl-passthrough" = ""
          "enable-ssl-chain-completion" = "false"
        }
        service = {
          type = "NodePort"
          nodePorts = {
            http  = 30080
            https = 30443
          }
        }
      }
    })
  ]
}

