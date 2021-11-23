param (
    [string]$storageName
)

$ignore = az storage account delete --resource-group GitHubActions-RG --name $storageName --yes
