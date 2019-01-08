$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psd1")
$moduleName = Split-Path $moduleRoot -Leaf

$assets = "$projectRoot\Tests\TestData"

Import-Module $moduleRoot -Force

Describe $moduleName -Tags Run, UnitTest, UT {

    Context "Example 1: Simple Use" {
        $Source = $assets
        $Target = 'TestDrive:\'
        Copy-Item $Source\* $Target -Recurse -Force
        Push-Location $Target

        Update-Lbi -Recurse

        Pop-Location

        It "index.html" {
            $Index = Get-Content 'TestDrive:\index.expected' -Encoding UTF8 -Raw
            Get-Content 'TestDrive:\index.html' -Encoding UTF8 -Raw | Should be $Index
        }

        It "test.html" {
            $Test = Get-Content 'TestDrive:\test.expected' -Encoding UTF8 -Raw
            Get-Content 'TestDrive:\test.html' -Encoding UTF8 -Raw | Should be $Test
        }
    }

    Context "Example 2: Update some Lbi only" {
        $Source = $assets
        $Target = 'TestDrive:\'
        Copy-Item $Source\* $Target -Recurse -Force
        Push-Location $Target

        Read-Lbi
        Update-Lbi -UseCachedLbiOnly

        Pop-Location

        It "index.html" {
            $Index = Get-Content 'TestDrive:\index.expected' -Encoding UTF8 -Raw
            Get-Content 'TestDrive:\index.html' -Encoding UTF8 -Raw | Should be $Index
        }

        It "test.html" {
            $Test = Get-Content 'TestDrive:\test.expected' -Encoding UTF8 -Raw
            Get-Content 'TestDrive:\test.html' -Encoding UTF8 -Raw | Should be $Test
        }
    }

    Context "Example 3: Update some files only" {
        $Source = $assets
        $Target = 'TestDrive:\'
        Copy-Item $Source\* $Target -Recurse -Force
        Push-Location $Target

        Reset-LbiCache | ForEach-Object {
            Update-Lbi 'TestDrive:\index.html' -SkipResetLbiCache
            Update-Lbi 'TestDrive:\test.html' -SkipResetLbiCache
        }

        Pop-Location

        It "index.html" {
            $Index = Get-Content 'TestDrive:\index.expected' -Encoding UTF8 -Raw
            Get-Content 'TestDrive:\index.html' -Encoding UTF8 -Raw | Should be $Index
        }

        It "test.html" {
            $Test = Get-Content 'TestDrive:\test.expected' -Encoding UTF8 -Raw
            Get-Content 'TestDrive:\test.html' -Encoding UTF8 -Raw | Should be $Test
        }
    }
}
