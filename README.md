[![ci](https://github.com/salem84/azure-resume-challenge/actions/workflows/ci.yml/badge.svg)](https://github.com/salem84/azure-resume-challenge/actions/workflows/ci.yml)

# Azure Resume Challenge
#### 'A Cloud Guru' challenge

## Infrastructure as Code
In order to manage Azure infrastructure resources, I have used a template based on Bicep, that provides a transparent abstraction of Azure Resource Manager (ARM) template.
In our specific usecase, Bicep template is composed of following resources:
* CosmosDb (Account, database, container)
* Storage Account 
* Function with Consumption Plan
* Application Insights

A Bicep template could be easily deployed to an Azure Resource Group using Azure CLI 

```
az deployment group create --resource-group AZURE_RESOURCEGROUP_NAME --template-file BICEP_TEMPLATE
```


Unfortunately some configuration cannot be 

## Resume
Based on beautiful resume template developed by [Ivan Greve](https://github.com/ivangreve/nuxt-resume)

## Azure Deployment Template
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fsalem84%2Fazure-resume-challenge%2Fmaster%2Fdeploy%2Fmain.json)



