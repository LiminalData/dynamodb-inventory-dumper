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
    try {
        $Table = Get-DdbTable -TableName $TableName | Select-Object *
    } catch {
        # Permissions errors are terminating
        Write-Warning $Error[0]
        # Try/catch captures the TableName for inventory
        #   and still raises the error to the caller
        $Table = [PSCustomObject]@{
            TableName = $TableName
        }
    }

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
