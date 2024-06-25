# setup-azurestorage-action

This action handles the setup and teardown of an Storage Accounts for running tests.

## Usage

```yaml
      - name: Setup infrastructure
        uses: Particular/setup-azurestorage-action@v1.0.0
        with:
          connection-string-name: EnvVarToCreateWithConnectionString
          azure-credentials: ${{ secrets.AZURE_ACI_CREDENTIALS }}
          tag: PackageName
```

## License

The scripts and documentation in this project are released under the [MIT License](LICENSE).

## Development

Open the folder in Visual Studio Code. If you don't already have them, you will be prompted to install remote development extensions. After installing them, and re-opening the folder in a container, do the following:

Log into Azure

```bash
az login
az account set --subscription SUBSCRIPTION_ID
```

When changing `index.js`, either run `npm run dev` beforehand, which will watch the file for changes and automatically compile it, or run `npm run prepare` afterwards.

## Testing

### With PowerShell

To test the setup action set the required environment variables and execute `setup.ps1` with the desired parameters.

```bash
$Env:RESOURCE_GROUP_OVERRIDE=yourResourceGroup
$Env:REGION_OVERRIDE=yourRegion
# Replace the principal ID with the appropriate principal ID that you used to log into AZ CLI
$azureCredentials = @"
{
     "principalId": "a28b36b8-2243-494e-9028-0e94df179913",
   }
"@
.\setup.ps1 -StorageName pswstorage-1 -ConnectionStringName AzureStorage_ConnectionString -Tag setup-azurestorage-action -AzureCredentials $azureCredentials
```

To test the cleanup action set the required environment variables and execute `cleanup.ps1` with the desired parameters.

```bash
$Env:RESOURCE_GROUP_OVERRIDE=yourResourceGroup
.\cleanup.ps1 -StorageName pswstorage-1
```