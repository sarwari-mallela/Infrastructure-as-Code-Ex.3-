// main.bicep
param location string
param containerRegistryName string
param containerRegistryImageName string
param containerRegistryImageVersion string
param appServicePlanName string
param webAppName string

module acr 'modules/container-registry.bicep' = {
  name: '${uniqueString(deployment().name, location)}-acr'
  params: {
    name: containerRegistryName
    location: location
    acrAdminEnabled: true
  }
}

module servicePlan 'modules/service-plan-linux.bicep' = {
  name: '${uniqueString(deployment().name, location)}-sp'
  params: {
    name: 'my-service-plan'
    location: location
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
      kind: 'Linux'
      reserved: true
    }
  }
}

module webApp 'modules/web-app-linux.bicep' = {
  name: webAppName
  params: {
    name: webAppName
    location: location
    kind: 'app'
    serverFarmResourceId: servicePlan.outputs.serverFarmResourceId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      DOCKER_REGISTRY_SERVER_URL: 'https://${containerRegistryName}.azurecr.io'
      DOCKER_REGISTRY_SERVER_USERNAME: acr.outputs.adminUsername
      DOCKER_REGISTRY_SERVER_PASSWORD: acr.outputs.adminPassword
    }
  }
}

output acrOutputs object = acr.outputs
output servicePlanOutputs object = servicePlan.outputs
output webAppOutputs object = webApp.outputs
