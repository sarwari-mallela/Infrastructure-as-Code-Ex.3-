param location string
param containerRegistryName string
param containerRegistryImageName string
param containerRegistryImageVersion string
param appServicePlanName string
param webAppName string


// var acrName = '${containerRegistryName}acr'

// containerRegistry deployment
module containerRegistry 'modules/container-registry/registry/main.bicep' = { 
  name: containerRegistryName
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
  }
}

// Azure Service Plan for Linux module deployment
module serverfarm 'modules/web/serverfarm/main.bicep' = {
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
module website 'modules/web/site/main.bicep' = {
  name: webAppName
  params: {
    name: webAppName
    location: location
    serverFarmResourceId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    kind: 'app'
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      // DOCKER_REGISTRY_SERVER_URL: 'https://${containerRegistryName}.azurecr.io'
      // DOCKER_REGISTRY_SERVER_USERNAME: 'sarwaricR'
      // DOCKER_REGISTRY_SERVER_PASSWORD: 'GvOBnhMayVXorEG+I3gDcUoSg9FIiBOnK5V8XJ0S5Q+ACRDdxEXc'
    }
  }
}
