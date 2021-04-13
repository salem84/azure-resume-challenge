$rgName = 'RG_ACGResume'
az group create --location northeurope --resource-group $rgName
az deployment group create --resource-group $rgName --template-file ./main.bicep