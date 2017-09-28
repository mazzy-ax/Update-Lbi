# Copyright (c) 2017 Sergey Mazurkin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# mazzy@mazzy.ru, 2017-09-28
# https://github.com/mazzy-ax/Update-Lbi
#

#requires -version 3.0

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Import-Module -Force ".\Update-Lbi.psm1"

Describe "Update-Lbi" {
    $Source = Join-Path $here 'TestData\*'
    $Target = 'TestDrive:\'
    Copy-Item $Source $Target -Recurse

    Update-LibItemsCli 'TestDrive:\*.html'

    It "index.html" {
        $Index = Get-Content 'TestDrive:\index.expected.html' -Encoding UTF8 -Raw
        Get-Content 'TestDrive:\index.html' -Encoding UTF8 -Raw | Should be $Index
    }

    It "test.html" {
        $Test = Get-Content 'TestDrive:\test.expected.html' -Encoding UTF8 -Raw
        Get-Content 'TestDrive:\test.html' -Encoding UTF8 -Raw | Should be $Test
    }
}
