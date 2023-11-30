// main.bicep
param location string
param containerRegistryName string
param containerRegistryImageName string
param containerRegistryImageVersion string
param appServicePlanName string
param webAppName string

module containerRegistry 'modules/container-registry/registry/main.bicep' = { 
  name: '${uniqueString(deployment().name)}-acr'
  params: {
    name: '${uniqueString(deployment().name)}-acr'
    location: location
    acrAdminUserEnabled: true
  }
}

// didn't add kind: 'Linux'
module serverfarm 'modules/web/serverfarm/main.bicep' = {
  name: '${uniqueString(deployment().name)}-asp'
  params: {
    name: '${uniqueString(deployment().name)}-asp'
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

module website 'modules/web/site/main.bicep' = {
  name: '${uniqueString(deployment().name)}-site'
  params: {
    name: '${uniqueString(deployment().name)}-site'
    location: location
    serverFarmResourceId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    kind: 'app' // Add this line
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
    }
  }
}


