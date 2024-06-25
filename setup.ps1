param (
    [string]$storageName,
    [string]$connectionStringName,
    [string]$tagName,
    [string]$azureCredentials
)

$credentials = $azureCredentials | ConvertFrom-Json

$resourceGroup = $Env:RESOURCE_GROUP_OVERRIDE ?? "GitHubActions-RG"

if ($Env:REGION_OVERRIDE) {
    $region = $Env:REGION_OVERRIDE
}
else {
    Write-Output "Getting the Azure region in which this workflow is running..."
      $hostInfo = curl --silent -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | ConvertFrom-Json
    $region = $hostInfo.compute.location
}

Write-Output "Actions agent running in Azure region $region"

$packageTag = "Package=$tagName"
$runnerOsTag = "RunnerOS=$($Env:RUNNER_OS)"
$dateTag = "Created=$(Get-Date -Format "yyyy-MM-dd")"

Write-Output "Creating storage account (This can take a while.)"
$storageDetails = az storage account create --name $storageName --location $region --resource-group $resourceGroup --sku Standard_LRS | ConvertFrom-Json

Write-Output "Assigning roles to Storage Account $storageName"
az role assignment create --assignee $credentials.principalId --role "Storage Account Contributor" --scope $storageDetails.id  > $null
az role assignment create --assignee $credentials.principalId --role "Storage Table Data Contributor" --scope $storageDetails.id  > $null
az role assignment create --assignee $credentials.principalId --role "Storage Queue Data Contributor" --scope $storageDetails.id  > $null
az role assignment create --assignee $credentials.principalId --role "Storage Blob Data Contributor" --scope $storageDetails.id  > $null

Write-Output "Getting storage account keys"
$storageKeyDetails = az storage account keys list --account-name $storageName --resource-group $resourceGroup | ConvertFrom-Json
$storageKey = $storageKeyDetails[0].value
Write-Output "::add-mask::$storageKey"

$blobEndpoint = $storageDetails.primaryEndpoints.blob
$uri = [System.Uri]$blobEndpoint
$uriHost = $uri.Host
$endpointSuffix = $uriHost.Substring($uriHost.IndexOf('.') + 1)
$endpointSuffix = $endpointSuffix.Substring($endpointSuffix.IndexOf('.') + 1)

$storageConnectString = "DefaultEndpointsProtocol=https;AccountName=$storageName;AccountKey=$storageKey;EndpointSuffix=$endpointSuffix"

Write-Output "Tagging storage account"
az tag create --resource-id $storageDetails.id --tags $packageTag $runnerOsTag $dateTag > $null

Write-Output "$connectionStringName=$storageConnectString" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf-8 -Append
