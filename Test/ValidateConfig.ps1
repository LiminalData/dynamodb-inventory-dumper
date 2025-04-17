#Requires -Modules @{ModuleName='Pester';ModuleVersion='6.0'}

Describe 'DynamoDB Inventory Dumper Global Defaults.' {
    It "The `$DidDefaults variable should exist." {
        Get-Variable DidDefaults | Should -Not -BeNullOrEmpty
    }
  
    It "At least one AWS Region should be assigned." {
        $DidDefaults.Regions.Count | Should -BeGreaterOrEqual 1
    }

    Describe "All Regions should be actual AWS Regions." {
        It "'<_>' is a known AWS Region." -ForEach $DidDefaults.Regions {
            $_ | Should -BeIn (Get-AWSRegion).Region
        }
    }

    It "The Target Directory variable should be mapped." {
        $DidDefaults.TargetFolderPath | Should -Not -BeNullOrEmpty
    }

    It "The Target Directory should exist." {
        Test-Path $DidDefaults.TargetFolderPath | Should -BeTrue
    }
}
