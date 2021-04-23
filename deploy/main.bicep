param appName string = uniqueString(resourceGroup().id)
param accountName string = toLower('cosmos-${appName}')
param location string = resourceGroup().location
param databaseName string = toLower('stats')
param containerName string = toLower('counters')

param functionAppName string = toLower('resume-functions-${appName}')
param appServicePlanName string = toLower('plan-${appName}')
param storageAccountName string = toLower('storage${appName}')

param deploymentScriptTimestamp string = utcNow()
param indexDocument string = 'index.html'
param errorDocument404Path string = 'error.html'

var storageAccountContributorRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '17d1049b-9a84-46fb-8f53-869881c3d3ab') // This is the Storage Account Contributor role, which is the minimum role permission we can give. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#:~:text=17d1049b-9a84-46fb-8f53-869881c3d3ab

resource appInsights 'Microsoft.Insights/components@2018-05-01-preview' = {
  name: toLower('appinsights-${appName}')
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
      ]
    }
    httpsOnly: true
  }
}

// resource function 'Microsoft.Web/sites/functions@2020-06-01' = {
//   name: '${functionAppName}/counter'
// }

// resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
//   name: 'DeploymentScript'
//   location: location
// }

// resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   scope: storageAccount
//   name: guid(resourceGroup().id, storageAccountContributorRoleDefinitionId)
//   properties: {
//     roleDefinitionId: storageAccountContributorRoleDefinitionId
//     principalId: managedIdentity.properties.principalId
//   }
// }

// resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
//   name: 'deploymentScript'
//   location: location
//   kind: 'AzurePowerShell'
//   identity: {
//     type: 'UserAssigned'
//     userAssignedIdentities: {
//       '${managedIdentity.id}': {}
//     }
//   }
//   dependsOn: [
//     roleAssignment
//     storageAccount
//   ]
//   properties: {
//     azPowerShellVersion: '3.0'
//     scriptContent: '''
// param(
//     [string] $ResourceGroupName,
//     [string] $StorageAccountName,
//     [string] $IndexDocument,
//     [string] $ErrorDocument404Path)
// $ErrorActionPreference = 'Stop'
// $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName
// $ctx = $storageAccount.Context
// Enable-AzStorageStaticWebsite -Context $ctx -IndexDocument $IndexDocument -ErrorDocument404Path $ErrorDocument404Path
// '''
//     forceUpdateTag: deploymentScriptTimestamp
//     retentionInterval: 'PT4H'
//     arguments: '-ResourceGroupName ${resourceGroup().name} -StorageAccountName ${accountName} -IndexDocument ${indexDocument} -ErrorDocument404Path ${errorDocument404Path}'
//   }
// }

// output scriptLogs string = reference('${deploymentScript.id}/logs/default', deploymentScript.apiVersion, 'Full').properties.log
// output staticWebsiteHostName string = replace(replace(storageAccount.properties.primaryEndpoints.web, 'https://', ''), '/', '')
output storageAccountName string = storageAccount.name
output functionAppName string = functionApp.name
