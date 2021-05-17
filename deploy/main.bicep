param rndSuffix string = uniqueString(resourceGroup().id)
param appName string = 'resume${rndSuffix}'

// Database settings
param accountName string = toLower('cosmos-${appName}')
param databaseName string = toLower('stats')
param containerName string = toLower('counters')

// Function settings
param functionAppName string = toLower('func-${appName}')
param appServicePlanName string = toLower('plan-${appName}')
param storageAccountName string = toLower('st${appName}')
param cdnProfileName string = toLower('cdnp-${appName}')
param cdnEndpointName string = toLower('cdne-${appName}')
param appInsightsName string = toLower('appi-${appName}')
// param endpointCompleteName string = concat(cdnProfileName, '/', cdnEndpointName)

param deploymentScriptTimestamp string = utcNow()
param indexDocument string = 'index.html'
param errorDocument404Path string = 'error.html'

var storageAccountContributorRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '17d1049b-9a84-46fb-8f53-869881c3d3ab') // This is the Storage Account Contributor role, which is the minimum role permission we can give. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#:~:text=17d1049b-9a84-46fb-8f53-869881c3d3ab

param location string = resourceGroup().location

resource appInsights 'Microsoft.Insights/components@2018-05-01-preview' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2020-04-01' = {
  name: accountName
  location: location
  properties: {
    enableFreeTier: false
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
      }
    ]
  }
}

resource cosmosdb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2020-04-01' = {
  name: '${cosmos.name}/${databaseName}'
  dependsOn: [
    cosmos
  ]
  properties: {
    resource: {
      id: databaseName
    }
    options: {
    }
  }
}

resource cosmoscontainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2020-04-01' = {
  name: '${cosmos.name}/${databaseName}/${containerName}'
  dependsOn: [
    cosmosdb
  ]
  properties: {
    resource: {
      id: containerName
    }
    options: {
      
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'    
  }
}

resource plan 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  kind: 'functionapp'
  sku: {
    name: 'Y1'
  }
  properties: {}
}

resource functionApp 'Microsoft.Web/sites@2020-06-01' = {
  name: functionAppName
  location: location
  dependsOn: [
    cosmos
  ]
  kind: 'functionapp'
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      cors: {
        allowedOrigins: [
          '*'
        ]
      }
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${appInsights.properties.InstrumentationKey}'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'ConnectionStrings:CosmosDb'
          value: listConnectionStrings(cosmos.id, '2020-04-01').connectionStrings[0].connectionString
        }
      ]
    }
    httpsOnly: true
  }
}

resource cdnProfile 'Microsoft.Cdn/profiles@2020-09-01' = {
  location: location
  name: cdnProfileName
  sku: {
    name: 'Standard_Microsoft'
  }
}

var storageAccountHostNameWeb = replace(replace(storageAccount.properties.primaryEndpoints.web, 'https://', ''), '/', '')

resource cdnEndpoint 'Microsoft.Cdn/profiles/endpoints@2020-09-01' = {
  location: location
  dependsOn: [
    storageAccount
    cdnProfile
  ]
  name: '${cdnProfileName}/${cdnEndpointName}'
  properties: {
    originHostHeader: storageAccountHostNameWeb
    isHttpAllowed: true
    isHttpsAllowed: true
    queryStringCachingBehavior: 'IgnoreQueryString'
    contentTypesToCompress: [
      'text/plain'
      'text/html'
      'text/css'
      'text/javascript'
      'application/x-javascript'
      'application/javascript'
      'application/json'
      'application/xml'
    ]
    isCompressionEnabled: true
    optimizationType: 'GeneralWebDelivery'
    origins: [
      {
        name: 'webstorageorigin'
        properties: {
          hostName: storageAccountHostNameWeb
          enabled: true
        }
      }
    ]
  }
}

// to avoid domain conflicts
// resource cdnCustomDomain 'Microsoft.Cdn/profiles/endpoints/customDomains@2020-09-01' = {
//   name: '${cdnProfileName}/${cdnEndpointName}/wwwdomain'
//   dependsOn: [
//     cdnEndpoint
//   ]
//   properties: {
//     hostName: 'www.giorgiolasala.space'
//   }
// }

// output scriptLogs string = reference('${deploymentScript.id}/logs/default', deploymentScript.apiVersion, 'Full').properties.log
// output staticWebsiteHostName string = replace(replace(storageAccount.properties.primaryEndpoints.web, 'https://', ''), '/', '')
output storageAccountName string = storageAccount.name
output functionAppName string = functionApp.name
output functionUrl string = concat('https://', functionApp.properties.defaultHostName)
output cdnProfileName string = cdnProfile.name
output cdnEndpointHostName string = cdnEndpoint.properties.hostName
output originHostHeader string = cdnEndpoint.properties.originHostHeader
output cdnEndpointName string = cdnEndpointName
