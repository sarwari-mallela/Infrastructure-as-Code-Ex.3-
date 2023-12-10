param location string
param containerRegistryName string
param appServicePlanName string
param webAppName string
param containerRegistryImageName string
param containerRegistryImageVersion string
param keyVaultName string

param keyVaultSecretNameACRUsername string = 'acr-username'
param keyVaultSecretNameACRPassword1 string = 'acr-password1'

//key vault reference
resource vault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
 }

// Azure Container Registry module
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: containerRegistryName
 }



// Azure Service Plan for Linux module deployment
module serviceplan 'modules/web/serverfarm/main.bicep' = {
  name: appServicePlanName
  params: {
    name: appServicePlanName
    location: location
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    reserved: true
  }
}

// Azure Web App for Linux containers module
module webApp './modules/web/site/main.bicep' = {
  name: webAppName
  dependsOn: [
    serviceplan
    acr
    vault
  ]
  params: {
    name: webAppName
    location: location
    kind: 'app'
    serverFarmResourceId: servicePlan.outputs.resourceId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
    }
    dockerRegistryServerUrl: 'https://${containerRegistryName}.azurecr.io'
    dockerRegistryServerUserName: vault.getSecret(keyVaultSecretNameACRUsername)
    dockerRegistryServerPassword: vault.getSecret(keyVaultSecretNameACRPassword1)
  }
}
