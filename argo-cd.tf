# Argo CD installation
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "5.46.8"

  create_namespace = true

  values = [
    file("values.yaml")
  ]
}

# NGINX Ingress installation
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
          "enable-ssl-passthrough"        = ""
          "enable-ssl-chain-completion"   = "false"
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

resource "kubernetes_manifest" "wordpress_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "wordpress-app"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/Rohit4530/argocd-project.git"
        targetRevision = "main"
        path           = "argocd-applications/v04-project"
        helm = {
          releaseName = "application-from-helm"
         #valueFiles  = ["custom-values.yaml"]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      syncPolicy = {
        automated = {
                prune    = true
                selfHeal = true
         }
      }
    }
  }
}

