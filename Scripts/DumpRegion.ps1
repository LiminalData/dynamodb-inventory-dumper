#Requires -Modules AWS.Tools.DynamoDbV2

[CmdletBinding()]Param(
    [ValidateScript({$_ -in (Get-AwsRegion).Region})]
    [string]
    $Region = $DidDefaults.Regions[0]
)

$PopRegion = $StoredAwsRegion
$PushRegion = "$Region"
Set-DefaultAwsRegion $PushRegion

$TableList = Get-DdbTableList | Sort-Object
$TableArray = @()

foreach($TableName in $TableList){
    $Table = Get-DdbTable -TableName $TableName | Select-Object *

    $TableArray += $Table | Select-Object @(
        'TableName'
        'CreationDateTime'
        'DeletionProtectionEnabled'
        @{
            n = 'TableStatus'
            e = {$Table.TableStatus.Value}
        }
        @{
            n = 'KeySchema'
            e = {
                    $Table.KeySchema | ForEach-Object {
                    @{
                        $_.AttributeName = $_.KeyType.Value
                    }
                } | ConvertTo-Json -Compress
            }
        }
        'TableArn'
        'TableId'
        @{
            n = 'ReadUnitsPerSecond'
            e = {$Table.WarmThroughput.ReadUnitsPerSecond}
        }
        @{
            n = 'WriteUnitsPerSecond'
            e = {$Table.WarmThroughput.WriteUnitsPerSecond}
        }
    )
}

New-Item -ItemType Directory -Path "$($DidDefaults.TargetFolderPath)/$PushRegion" -Force | Out-Null
$TableArray | Export-Csv "$($DidDefaults.TargetFolderPath)/$PushRegion/Inventory.csv" -UseQuotes AsNeeded

Set-DefaultAwsRegion $PopRegion
