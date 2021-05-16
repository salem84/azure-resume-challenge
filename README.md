[![ci](https://github.com/salem84/azure-resume-challenge/actions/workflows/ci.yml/badge.svg)](https://github.com/salem84/azure-resume-challenge/actions/workflows/ci.yml)

# Azure Resume Challenge

Hi guys 👋👋👋

this is the repository for my first [A Cloud Guru Challenge](https://acloudguru.com/blog/engineering/cloudguruchallenge-your-resume-in-azure) to create a web resume using Azure infrastructure!

The site url is [www.giorgiolasala.space](https://www.giorgiolasala.space).

Thanks to [Amen.pt](https://www.amen.pt/) for the free domain 🙏 used in this challenge!

## Infrastructure as Code
In order to manage Azure infrastructure resources, I have used a template based on Bicep, that provides a transparent abstraction of Azure Resource Manager (ARM) template.

In our specific usecase, Bicep template is composed of following resources:
* _CosmosDb_ (Account, database, container)
* _Storage Account_ 
* _Function_ with Consumption Plan
* _Application Insights_

A Bicep template could be easily deployed to an Azure Resource Group using Azure CLI 

```
az deployment group create --resource-group AZURE_RESOURCEGROUP_NAME --template-file BICEP_TEMPLATE
```

Unfortunately some configuration cannot be directly applied from Bicep/ARM deployment template, such as Static Website configuration.
But... 🚀 GitHub Workflows are the rescue!

Moreover in order to create workflows completely indipendent from specific resource names, I have exported some output variables from Bicep template itself to be used directly in GitHub Workflow.

Indeed, at the begininnig of Bicep template, resource names are "randomized", generating a deterministic unique string based on Resource Group name:

```
param appName string = uniqueString(resourceGroup().id)
```

and at the end of file, there are all exported values used during deployment phase; in particular I have:
* _StorageAccountName_ to deploy resume static files after Nuxt build
* _FunctionUrl_ to deploy Azure Function
* _Cdn_ information to purge after deployment

### Azure Deployment button
During creation of Bicep template, I have learned that Azure Button can be attached only to ARM templates. Maybe this issue will be solved in the future (Bicep templates are quite young :) ), but in the meantime I have created a [CI build](.github/workflows/bicep.yml) that generates automatically ARM template and a 🤖 GitHub Bot user commits JSON file directly into the repository.

Finally, it's possible to link Json ARM file to a Deployment button such as:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fsalem84%2Fazure-resume-challenge%2Fmaster%2Fdeploy%2Fmain.json)

This button isn't necessary for Azure Resume challenge project, but however I would like sharing this 'pork-around' 🐷!

## GitHub Workflow

## Azure Function


## Resume Template


## Thanks

Resume templates is based on beautiful resume NUXT code developed by [Ivan Greve](https://github.com/ivangreve/nuxt-resume) and [StartBootstrap Theme](https://github.com/startbootstrap/startbootstrap-resume/).

All users in Discord "A Cloud Guru" channel for suggestion and ideas!

