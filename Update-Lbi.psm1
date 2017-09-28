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

<#
.SYNOPSIS
This module updates Dreamweaver library items (LBI) within html-files.

.DESCRIPTION
The module splits each Html file into fragments: raw html fragments and library items (LibItem).
Then the module update content for all LibItem relative a lbi-file.
Finally the module merge all fragments and save it to html-file.

A HtmlFragment contains a raw html. It never updated.

A LibItem contains a special html fragment:
* started with a html-comment <!-- #BeginLibraryItem "LibraryDir\FileName.lbi" -->
* and ended with a html-comment <!-- #EndLibraryItem -->

.LINK
https://helpx.adobe.com/dreamweaver/using/library-items.html
#>

Class HtmlFragment {
    [String]$Value

    HtmlFragment (
        [String]$Value
    ) {
        $this.Value = $Value
    }

    [HtmlFragment]Update([String]$BaseDir) {
        return $this
    }

    [String]Text([String]$Indent = '') {
        # It ignores $Indent. See derived classes.
        return $this.Value
    }

    [String]LastLineIndent([String]$PreviousIndent = '') {
        if ( $this.Value -match '(?<indent>\n\s*)(?:.*)$' ) {
            return $Matches['indent']
        }

        return $PreviousIndent
    }
}

Class LibItem : HtmlFragment {
    [String]$FileName
    [String]$Begin
    [String]$End

    Static [Hashtable] $Cache = @{} # See Reset-LibItemCache

    LibItem (
        [String]$Value,
        [String]$FileName,
        [String]$Begin = "<!-- #BeginLibraryItem `"$FileName`" -->",
        [String]$End = "<!-- #EndLibraryItem -->"
    ) : base($Value) {
        $this.FileName = $FileName
        $this.Begin = $Begin
        $this.End = $End
    }

    [HtmlFragment]Update([String]$BaseDir) {
        $File = Join-Path -Path $BaseDir -ChildPath $this.FileName

        if ( $File -in $this::Cache.Keys ) {
            Write-Verbose "Read from the cache. Key='$File'"
            return $this::Cache[$File]
        }

        if ( Test-Path $File ) {
            Write-Verbose "Read from the file '$File'"
            $Text = Get-Content -LiteralPath $File -Encoding UTF8 -Raw
            $Parts = $Text -split '<meta.*?charset=utf-8.*?>'
            $this.Value = -join $Parts
            Write-Verbose "Lbi from file '$this.FileName' in the directory '$BaseDir'."

            Write-Verbose "set cache: key='$file'"
            $this::Cache[$File] = $this
        }
        else {
            # TODO ?add to cache to avoid redundant Test-Path?
            Write-Warning "Lbi '$this.FileName' is not found in the directory '$BaseDir'. Inner text is not changed."
        }

        return $this
    }

    [String]Text([String]$Indent = '') {
        $Text = ([HtmlFragment]$this).Text($Indent)

        # TODO  to Cache or not to Cache?
        if ( $Indent -and ($Indent -ne '\n') ) {
            $Text = $Text -replace '\n', $Indent
        }

        return -join ($this.Begin, $Text, $this.End)
    }

    [String]LastLineIndent([String]$PreviousIndent = '') {
        # A LibItem never changes the indent. See HtmlFragment
        return $PreviousIndent
    }
}

<#
.SYNOPSIS
Reset library item cache - the Update-LibItems cmdlets should read lbi-files once again.

.PARAMETER SkipIt
Do not reset cache if $true.
#>
function Reset-LibItemCache {
    [CmdletBinding()]
    Param (
        [switch]$SkipIt
    )

    if ( -not $SkipIt ) {
        [LibItem]::Cache = @{}
    }
}

<#
.SYNOPSIS
Gets an fragments from an HtmlText.

.DESCRIPTION
It splits an HTMLText into fragments and returns all fragments.

.PARAMETER HtmlText
Whole html text.

.EXAMPLE
Get-Content example.html -raw | Get-LibItem
#>
function Get-LibItem {
    [CmdletBinding()]
    [OutputType([HtmlFragment])]
    Param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$HtmlText
    )

    process {
        $HtmlText -split '(<!-- #BeginLibraryItem ".*?" -->[\s\S]*?<!-- #EndLibraryItem -->)' | ForEach-Object {
            if ( $_ -match '^(?<Begin><!-- #BeginLibraryItem "(?<filename>.*?)" -->)(?<Value>[\s\S]*?)(?<End><!-- #EndLibraryItem -->)$' ) {
                [LibItem]::New($Matches['Value'], $Matches['filename'], $Matches['Begin'], $Matches['End'])
            }
            elseif ( $_ ) {
                [HtmlFragment]::New($_)
            }
        }
    }
}

<#
.SYNOPSIS
Updates fragments

.PARAMETER BaseDir
Base directory for library files.
The default location is the current directory.

.PARAMETER Fragment
[HtmlFragment] or derived [LibItems] objects
#>
function Update-LibItem {
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [String]$BaseDir = (Get-Location),

        [Parameter(Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [HtmlFragment]$Fragment
    )

    process {
        $Fragment.Update($BaseDir)
    }
}

<#
.SYNOPSIS
Merge all fragments. It indents LibItems by a last line in previous html fragment.

.PARAMETER Fragments
[HtmlFragment] and [LibItem]
#>
function Merge-LibItem {
    [CmdletBinding()]
    [OutputType([String])]
    Param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [HtmlFragment[]]$Fragments
    )

    begin {
        $Html = [System.Text.StringBuilder]::new()
        $IdentStr = ''
    }

    process {
        foreach ($Fragment in $Fragments) {
            [void]$Html.Append($Fragment.Text($IdentStr))
            $IdentStr = $Fragment.LastLineIndent($IdentStr)
        }
    }

    end {
        $Html.ToString()
    }
}

<#
.SYNOPSIS
Update all LibItems in one html file.

.PARAMETER FileName
An html file name.

.PARAMETER BaseDir
Base directory for library files.
The default location is the current directory.

.PARAMETER Force
Forces the set-content to set the contents of a file, even if the file is read-only.

.LINK
set-content
#>
function Update-LibItems {
    [cmdletbinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]]$FileName,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$BaseDir = (Get-Location),

        [switch]$Force
    )

    process {
        $FileName | ForEach-Object {
            if ( Test-Path $_ ) {
                Write-Output "BaseDir='$BaseDir'. Upate LBI in file '$_'"

                $Html = Get-Content -LiteralPath $_ -Encoding UTF8 -Raw |
                    Get-LibItem |
                    Update-LibItem -BaseDir $BaseDir |
                    Merge-LibItem

                $Html | Out-File -FilePath $_ -Encoding UTF8 -NoNewline -Force:$Force
            }
            else {
                Write-Error "File '$_' not found."
            }
        }
    }
}

<#
.SYNOPSIS
Update lbi in several html files.

.DESCRIPTION
The cmdlet provide useful features:
* default values to easy updates all html file from site root directory
* maintain wildcards
* show progress bar (TODO)
* parallel updates - each html file in separate thread (TODO)

.PARAMETER Path
Specifies a path to the site root.
Wildcards are permitted. The default path is all files in the current directory.

.PARAMETER Include
Gets only the specified items. The value of this parameter qualifies the -Path parameter. Enter a path element or pattern, such as "*.html".
Wildcards are permitted. The default value is "*.html", "*.htm"

.PARAMETER Exclude
Omits the specified items. The value of this parameter qualifies the -Path parameter.
Wildcards are permitted.

.PARAMETER BaseDir
Base directory for library files.
The default location is the current directory.

.PARAMETER Recurse
Gets the files in the specified path and in all child directory.

.PARAMETER Force
Forces the set-content to set the contents of a file, even if the file is read-only.

.PARAMETER SkipResetLibItemCache
Do not reset library item cache - the Update-LibItems cmdlets should read lbi-files once again.

.LINK
set-content
#>
function Update-Lbi {
    [cmdletbinding()]
    param(
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [String[]]$Path = (Join-Path (Get-Location) "*"),
        [String[]]$Include = @("*.html", "*.htm"),
        [String[]]$Exclude,
        [String]$BaseDir = (Split-Path $Path -Parent),
        [switch]$Recurse,
        [switch]$Force,
        [switch]$SkipResetLibItemCache
    )

    process {
        Write-Verbose "Update Dreamveawer library items (Lbi) in files."
        Write-Verbose "Path=$Path"
        Write-Verbose "Include=$Include"
        Write-Verbose "Exclude=$Exclude"
        Write-Verbose "Recurse=$Recurse"

        # TODO is it more effective with a parallel updating?
        # see native 'foreach -parallel' and
        # https://github.com/RamblingCookieMonster/Invoke-Parallel
        # https://github.com/powercode/PSParallel

        # TODO add progress bar
        # https://github.com/mazzy-ax/Write-ProgressEx

        Reset-LibItemCache -SkipIt:$SkipResetLibItemCache

        Get-ChildItem $Path -Include $Include -Exclude $Exclude -Recurse:$Recurse |
            Update-LibItems -BaseDir $BaseDir

        Reset-LibItemCache -SkipIt:$SkipResetLibItemCache
    }
}

Export-ModuleMember `
    -Cmdlet Update-Lbi, Get-LibItem, Update-LibItem, Merge-LibItem, Update-LibItems, Reset-LibItemCache `
    -Function Update-Lbi, Get-LibItem, Update-LibItem, Merge-LibItem, Update-LibItems, Reset-LibItemCache
