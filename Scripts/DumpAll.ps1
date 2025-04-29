
Push-Location $PsScriptRoot

foreach($Region in $DidDefaults.Regions){
    . ./DumpRegion.ps1 -Region $Region
}

Pop-Location
