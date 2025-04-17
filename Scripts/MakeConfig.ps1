
Push-Location $PsScriptRoot

$ConfigFolderPath = "~/.DynamoDbInventoryDumper"

if(-not (Test-Path $ConfigFolderPath)){
    New-Item $ConfigFolderPath -ItemType Directory
    Copy-Item ../Config/Example.json -Destination $ConfigFolderPath/Config.json
    Write-Output "Config initialized for DynamoDbInventoryDumper. Please review and modify as needed."
    Invoke-Item $ConfigFolderPath/Config.json
}

Pop-Location
