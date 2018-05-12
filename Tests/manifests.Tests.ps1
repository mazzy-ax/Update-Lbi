$projectRoot = Resolve-Path $PSScriptRoot\..
$moduleRoot = Split-Path (Resolve-Path $projectRoot\*\*.psd1)
$moduleName = Split-Path $moduleRoot -Leaf

$changelog = 'CHANGELOG.md'
$readme = 'README.md'

$script:manifest = $null

Describe 'Module Manifest Tests' -Tag Meta {

    It 'has a valid module manifest file' {
        $script:manifest = Test-ModuleManifest -Path $moduleRoot\$moduleName.psd1
        $? | Should -Be $true
    }

    It 'has a valid name in the manifest' {
        $manifest.Name | Should -Be $moduleName
    }

    It 'has a valid guid in the manifest' {
        $manifest.Guid -as [guid] | Should -Not -BeNullOrEmpty
    }

    It 'has a description in the manifest' {
        $manifest.Description | Should -Not -BeNullOrEmpty
    }

    It 'has release notes in the manifest' {
        $manifest.PrivateData.PSData.ReleaseNotes | Should -Not -BeNullOrEmpty
    }

    $publicFunctions = (Get-ChildItem -Path $moduleRoot\Functions\*.ps1).baseName

    It 'has valid functions to export' {
        $manifest.ExportedFunctions.Keys | Sort-Object | Should -Be $publicFunctions
    }

    It 'has valid cmdlets to export' {
        $manifest.ExportedCmdlets.Keys | Sort-Object | Should -Be $publicFunctions
    }

    It 'has a valid version in the manifest' {
        $manifest.Version -as [Version] | Should -Not -BeNullOrEmpty
    }

    It "has a valid version on the top of $projectRoot\$changelog" {
        Get-Content -Path $projectRoot\$changelog |
            Where-Object { $_ -match '^\D*(?<Version>(\d+\.){1,3}\d+)' } | 
            Select-Object -First 1 | Should -Not -BeNullOrEmpty

        $script:ChangelogVersion = $matches.Version
        $ChangelogVersion                | Should -Not -BeNullOrEmpty
        $ChangelogVersion -as [Version]  | Should -Not -BeNullOrEmpty
    }

    It 'changelog and manifest versions are the same' {
        $manifest.Version -as [Version] | Should -Be ( $ChangelogVersion -as [Version] )
    }

    It 'description have not back quote' {
        $manifest.Description | Should -Not -Match '`'
    }

    It 'release notes have not back quote' {
        $manifest.PrivateData.PSData.ReleaseNotes | Should -Not -Match '`'
    }
}

Describe 'Nuget specification Tests' -Tag Meta {

    It 'has a valid nuspec file' {
        $file = Resolve-Path $projectRoot\$moduleName.nuspec
        [xml]$script:nuspec = Get-Content $file
        $nuspec | Should -Not -BeNullOrEmpty
    }

    It 'has a valid id' {
        $nuspec.package.metadata.id | Should -Be $moduleName
    }

    It 'nuspec and manifest descriptions are same' {
        $nuspec.package.metadata.Description | Should -Be $manifest.Description
    }

    It 'nuspec and manifest release notes are same' {
        $nuspecReleaseNotes = $nuspec.package.metadata.ReleaseNotes -replace '\s'
        $manifestReleaseNotes = $manifest.PrivateData.PSData.ReleaseNotes -replace '\s'
        
        $nuspecReleaseNotes | Should -Be $manifestReleaseNotes
    }

    It 'nuspec and manifest projectUrl are same' {
        $nuspec.package.metadata.projectUrl | Should -Be $manifest.PrivateData.PSData.ProjectUri
    }

    It 'nuspec and manifest licenseUrl notes are same' {
        $nuspec.package.metadata.licenseUrl | Should -Be $manifest.PrivateData.PSData.LicenseUri
    }

}

Describe "$readme Tests" -Tag Meta {

    It "has a valid shields.io/badge/version in the $readme file" {
        Get-Content -Path $projectRoot\$readme |
            Where-Object { $_ -match '\[version\.svg\]:https://img\.shields\.io/badge/version-(?<Version>(\d+\.){1,3}\d+)-green\.svg' } | 
            Select-Object -First 1

        $ReadmeVersion = $Matches.Version
        $ReadmeVersion | Should -Be $manifest.Version
    }
}