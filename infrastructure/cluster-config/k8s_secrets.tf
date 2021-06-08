data "azuread_client_config" "current" {
}

locals {
  tenant_id = data.azuread_client_config.current.tenant_id
}

resource "kubernetes_secret" "storage_service_principal" {
  metadata {
    name = "ml-app-secret"
    labels = {
      team = "ml-team"
      env  = var.environment
    }
  }
  data = {
    AZURE_CLIENT_ID     = var.storage_secret.principal_id
    AZURE_TENANT_ID     = local.tenant_id
    AZURE_CLIENT_SECRET = var.storage_secret.principal_secret
  }

  type = "Opaque"

}
