$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Import-Module -Force ".\Update-Lbi.psm1"

Describe "Update-Lbi" {
    $Source = Join-Path $here 'TestData\*'
    $Target = 'TestDrive:\'
    Copy-Item $Source $Target -Recurse

    Update-LibItemsCli 'TestDrive:\*.html'

    It "index.html" {
        $Index = Get-Content 'TestDrive:\index.expected' -Encoding UTF8 -Raw
        Get-Content 'TestDrive:\index.html' -Encoding UTF8 -Raw | Should be $Index
    }

    It "test.html" {
        $Test = Get-Content 'TestDrive:\test.expected' -Encoding UTF8 -Raw
        Get-Content 'TestDrive:\test.html' -Encoding UTF8 -Raw | Should be $Test
    }
}
