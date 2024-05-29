param (
    [string]$storageName,
    [string]$connectionStringName,
    [string]$tagName
)

echo "Getting the Azure region in which this workflow is running..."
  $hostInfo = curl --silent -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | ConvertFrom-Json
$region = $hostInfo.compute.location
echo "Actions agent running in Azure region $region"

$packageTag = "Package=$tagName"
$runnerOsTag = "RunnerOS=$($Env:RUNNER_OS)"
$dateTag = "Created=$(Get-Date -Format "yyyy-MM-dd")"

echo "Creating storage account (This can take a while.)"
$storageDetails = az storage account create --name $storageName --location $region --resource-group GitHubActions-RG --sku Standard_LRS | ConvertFrom-Json

echo "Getting storage account keys"
$storageKeyDetails = az storage account keys list --account-name $storageName --resource-group GitHubActions-RG | ConvertFrom-Json
$storageKey = $storageKeyDetails[0].value
echo "::add-mask::$storageKey"

$blobEndpoint = $storageDetails.primaryEndpoints.blob
$uri = [System.Uri]$blobEndpoint
$uriHost = $uri.Host
$endpointSuffix = $uriHost.Substring($uriHost.IndexOf('.') + 1)
$endpointSuffix = $endpointSuffix.Substring($endpointSuffix.IndexOf('.') + 1)

$storageConnectString = "DefaultEndpointsProtocol=https;AccountName=$storageName;AccountKey=$storageKey;EndpointSuffix=$endpointSuffix"

echo "Tagging storage account"
$ignore = az tag create --resource-id $storageDetails.id --tags $packageTag $runnerOsTag $dateTag

echo "$connectionStringName=$storageConnectString" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf-8 -Append
