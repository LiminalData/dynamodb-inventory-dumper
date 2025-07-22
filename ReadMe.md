# DynamoDB Inventory Dumper

Scripts to enumerate DynamoDB assets in a given tenant.

## Usage

```PowerShell
./Scripts/LoadConfig.ps1
./Scripts/DumpAll.ps1
```

## Config

The [sample config](Config/Example.json) reveals current functionality. It lives at `~/.DynamoDbInventoryDumper` when deployed.

```json
{
    "Regions": [
        "us-east-1",
        "us-east-2"
    ],
    "TargetFolderPath": "~/Desktop/DynamoDbInventory"
}
```

The [enumeration script](Scripts/ListRegionsWithDdbAssets.ps1) will optionally update your config's `.Regions` node when new assets are discovered.

The `.TargetFolderPath` is a directory you should set aside for the inventory files.
