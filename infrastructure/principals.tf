// Service principal to access storage inside Kubernetes
// TODO: Use managed identity once the support improves for AKS
// INFO https://docs.microsoft.com/en-us/azure/aks/use-azure-ad-pod-identity
resource "azuread_application" "pod_runner" {
  display_name = "pod_runner"
}

resource "azuread_service_principal" "pod_runner" {
  application_id = azuread_application.pod_runner.application_id
  tags           = [var.environment]
}

resource "random_password" "pod_runner" {
  length  = 20
  special = true
}

resource "azuread_service_principal_password" "pod_runner" {
  service_principal_id = azuread_service_principal.pod_runner.id
  value                = random_password.pod_runner.result
}

resource "azurerm_role_assignment" "pod_runner_storage_assignment" {
  scope                            = azurerm_storage_account.k8s_storage.id
  role_definition_name             = "Storage Blob Data Reader"
  principal_id                     = azuread_service_principal.pod_runner.object_id
  skip_service_principal_aad_check = true
}
