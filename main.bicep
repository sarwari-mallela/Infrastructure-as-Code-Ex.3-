param location string
param containerRegistryName string
param containerRegistryImageName string
param containerRegistryImageVersion string
param appServicePlanName string
param webAppName string

var acrName = '${containerRegistryName}acr'

// containerRegistry deployment
module containerRegistry 'modules/container-registry/registry/main.bicep' = { 
  name: acrName
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
  }
}

// appServicePlan deployment
module serverfarm 'modules/web/serverfarm/main.bicep' = {
  name: '${uniqueString(deployment().name)}asp'
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

// webApp deployment
module website 'modules/web/site/main.bicep' = {
  name: '${uniqueString(deployment().name)}site'
  params: {
    name: webAppName
    location: location
    serverFarmResourceId: resourceId('Microsoft.Web/serverfarms', appServicePlanName)
    siteConfig: {
      linuxFxVersion: 'DOCKER|${acrName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    kind: 'app'
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      DOCKER_REGISTRY_SERVER_URL: 'https://${acrName}.azurecr.io'
      DOCKER_REGISTRY_SERVER_USERNAME: 'sarwaricR'
      DOCKER_REGISTRY_SERVER_PASSWORD: 'GvOBnhMayVXorEG+I3gDcUoSg9FIiBOnK5V8XJ0S5Q+ACRDdxEXc'
    }
  }
}
