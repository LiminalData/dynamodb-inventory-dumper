#Requires -Modules AWS.Tools.DynamoDbV2
#Requires -Modules AWS.Tools.Account

<#
.Synopsis
    Check all enabled AWS Regions for DynamoDB assets. Optionally update local config.
#>

[CmdletBinding()]Param()

$Regions = @()

Get-AcctRegionList -MaxResult 50 | Where-Object {
    $_.RegionOptStatus -eq 'ENABLED_BY_DEFAULT'
} | ForEach-Object {
    if(0 -lt (Get-DdbTableList -Region $_.RegionName).Count){
        $Regions += $_.RegionName
    }
}

# if `$Regions is `$null, this will NOT execute by design
#   this prevents an expired login token from prompting you to clobber your config
if(Compare-Object $Regions $DidDefaults.Regions){
    Write-Warning "Config Regions differ from enumerated regions containing DynamoDB assets."
    Write-Warning "Config Regions: [$(($DidDefaults.Regions | Sort-Object) -join ',')]"
    Write-Warning "Discovered DynamoDB assets in Regions: [$(($Regions | Sort-Object) -join ',')]"
    $Response = 'x'
    while($Response -NotIn ('Y','N','Yes','No')){
        $Response = Read-Host "Would you like to clobber the existing config with the currently enumerated Regions? [Y/N]" 
    }
    if($Response -In ('Y','Yes')){
        Set-Variable DidDefaults -Option None -Value $DidDefaults -Force
        $DidDefaults.Regions = $Regions
        Set-Variable DidDefaults -Option ReadOnly

        $ConfigFilePath = '~/.DynamoDbInventoryDumper/Config.json'
        Copy-Item $ConfigFilePath "~/.DynamoDbInventoryDumper/Config-$(Get-Date -Format FileDateTimeUniversal).json"
        $DidDefaults | ConvertTo-Json | Set-Content $ConfigFilePath
    }
}
