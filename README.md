# Coding Challenge - DevOps Engineer

## How to get started locally

### Local requirements

- [Terraform](https://www.terraform.io/downloads.html)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

### First you need to login in azure

```
az login
```

### Create resource group and storage account for the terraform states

```
az group create -n infrastructure -l westeurope
az storage account create -n filesforplatform -g infrastructure -l westeurope --sku Standard_LRS
az storage container create -n terraformstates --account-name filesforplatform
```

### Run terraform locally

Once the Azure setup is done you run `cd infrastructure` and run

```
terraform init
```

then create a terraform plan

```
terraform plan -out tfplan 
```

and ultimately apply it

```
terraform apply tfplan  
```

### Get Access to the AKS Cluster

```
az aks get-credentials -n dev-ml-cluster -g platform  
```

## CI/CD

To set up the CI/CD we need to create a service principal, though a manually tedious process, it has to be done only once.

### Create a service principal

```
az ad sp create-for-rbac --role Owner \
--scopes /subscriptions/<YOUR-SUBSCRIPTION-ID-HERE> \
--name cicd-principal \
--sdk-auth
```

The output should be similar to this:

```
{
  "clientId": "2effba48-da00-44a0-a890-f7ff2edf634e",
  "clientSecret": "rF_mUp3U3Ytlz11KOXz4vjpPN05SuH60L8",
  "subscriptionId": "4d8ba129-43f2-4dff-9395-a4e68777149e",
  "tenantId": "0c6071bb-40a4-7884-a502-5065d44e58ec",
}
```

This is your `AZURE_CREDENTIALS`, you'll need them to set up the CI/CD for the application.

Here comes the most boring part, we need to manually grant some permissions to our newly created service principal.

You can follow the [terraform documentation](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_configuration#method-2-api-access-with-admin-consent).

> NOTE

The azure service principal for app CI/CD and infrastructure CI/CD should be different because they require different permissions.

Ideally, the app CI/CD service principal should be partly defined as part of the infrastructure.

### Set-up infrastructure CI/CD

The CI/CD for the infrastructure has different behaviors:

- on a PR:
    - runs linters of the terraform files
    - runs terraform plan to see which changes will be applied

- on main:
    - runs terraform plan
    - runs terraform apply

Before settings this pipeline up you need to set these secrets:

- ARM_CLIENT_ID: Azure Service principal application id
- ARM_CLIENT_SECRET: Azure Service principal password
- ARM_TENANT_ID: Azure tenant id
- ARM_SUBSCRIPTION_ID: Azure subscription id

### Set-up app CI/CD

The CI/CD for the app has different behaviors:

- on a PR:
    - build the docker image
    - runs tests and linters

- on main:
    - build the image
    - runs tests and linters
    - deploy to kubernetes

Before settings this pipeline up you need to set these secrets:

- REGISTRY_NAME: The azure registry name
- REGISTRY_USERNAME: Azure Service principal application id
- REGISTRY_PASSWORD: Azure Service principal password
- CLUSTER_NAME: The AkS cluster name, you can get this from the terraform output
- CLUSTER_RESOURCE_GROUP: The AKS cluster resource group name, you can get this from the terraform output
- AZURE_CREDENTIALS: the output of `Create a service principal`

## S.O.S.

In case you need help, please slack your #platform-team.
