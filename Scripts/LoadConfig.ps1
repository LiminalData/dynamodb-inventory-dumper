
$ConfigFolderPath = "~/.DynamoDbInventoryDumper"
$ConfigFilePath = "$ConfigFolderPath/Config.json"

if(-not (Test-Path $ConfigFilePath)){
    Write-Error "Config file not found for DynamoDbInventoryDumper. Please initialize config."
    break
}

$Config = Get-Content $ConfigFilePath -Raw | ConvertFrom-Json

New-Variable `
    -Name DidDefaults `
    -Scope Global `
    -Force `
    -Value $Config `
    -Option ReadOnly
;
