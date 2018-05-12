# mazzy@mazzy.ru, 2017-10-01
# https://github.com/mazzy-ax/Update-Lbi

#requires -version 3.0

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Import-Module -Force ".\Update-Lbi.psm1"

Describe "Update-Lbi" {

    Context "Example 1: Simple Use" {
        $Source = Join-Path $here 'TestData\*'
        $Target = 'TestDrive:\'
        Copy-Item $Source $Target -Recurse -Force
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
        $Source = Join-Path $here 'TestData\*'
        $Target = 'TestDrive:\'
        Copy-Item $Source $Target -Recurse -Force
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
        $Source = Join-Path $here 'TestData\*'
        $Target = 'TestDrive:\'
        Copy-Item $Source $Target -Recurse -Force
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
