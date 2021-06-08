// The ingress needs at least one rule to be deployed
// Uncomment this file and run terraform again once
// the service has been deployed

# resource "kubernetes_ingress" "development-ingress" {
#   metadata {
#     name = "${var.environment}-ingress"
#     annotations = {
#       "kubernetes.io/ingress.class"              = "nginx"
#       "nginx.ingress.kubernetes.io/ssl-redirect" = "false"
#     }
#   }

#   spec {

#     rule {
#       http {
#         path {
#           backend {
#             service_name = "ml-app"
#             service_port = 80
#           }

#           path = "/*"
#         }

#       }
#     }

#   }
# }
