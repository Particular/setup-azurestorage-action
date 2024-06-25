param (
    [string]$storageName
)

az storage account delete --resource-group GitHubActions-RG --name $storageName --yes > $null
