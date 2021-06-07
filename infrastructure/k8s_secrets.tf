data "azuread_client_config" "current" {
}

locals {
  tenant_id = data.azuread_client_config.current.tenant_id
}

resource "kubernetes_secret" "aratrum" {
  metadata {
    name = "ml-app-secret"
    labels = {
      team = "ml-team"
      env  = var.environment
    }
  }
  data = {
    AZURE_CLIENT_ID     = azuread_service_principal.pod_runner.object_id
    AZURE_TENANT_ID     = local.tenant_id
    AZURE_CLIENT_SECRET = azuread_service_principal_password.pod_runner.value
  }

  type = "Opaque"

}
