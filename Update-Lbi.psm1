# mazzy@mazzy.ru, 2017-10-01
# https://github.com/mazzy-ax/Update-Lbi

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

    [HtmlFragment]Update([switch]$UseCachedLbiOnly) {
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

    Static [Hashtable] $Cache = @{} # See Reset-LbiCache

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

    [HtmlFragment]Update([switch]$UseCachedLbiOnly) {
        if ( $this.FileName -in $this::Cache.Keys ) {
            Write-Verbose "Read from the cache. Key='$This.FileName'"
            $this.Value = $this::Cache[$this.FileName]
        }
        elseif ( $UseCachedLbiOnly ) {
            Write-Warning "Lbi '$this.FileName' was not found in the cache and the UseCachedLbiOnly is switch on. Inner text is not changed."
        }
        else {
            try {
                $this.Value = Read-LibItem $this.FileName
            }
            catch {
                # TODO ?add to cache to avoid redundant Test-Path?
                Write-Warning "Lbi '$this.FileName' was not readed. Inner text is not changed."
            }
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
function Reset-LbiCache {
    [CmdletBinding()]
    [OutputType([void])]
    Param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName = $true)]
        [switch]$SkipIt
    )

    begin {
        if ( -not $SkipIt ) {
            [LibItem]::Cache = @{}
        }
    }

    process {
        [LibItem]::Cache
    }

    end {
        if ( -not $SkipIt ) {
            [LibItem]::Cache = @{}
        }
    }
}


<#
.SYNOPSIS
Read a Lbi from files and update cache.

.PARAMETER File
A literal path to Lbi-files.

.NOTES
Throw error if a file is not found.
#>
function Read-LibItem {
    [CmdletBinding()]
    [OutputType([string[]])]
    Param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]]$LiteralPath,

        [switch]$SkipUpdateLbiCache
    )

    process {
        foreach($File in $LiteralPath) {
            Write-Verbose "Read Lbi from the file '$File'"
            $Text = Get-Content -LiteralPath $File -Encoding UTF8 -Raw     # throw is possible
            Write-Verbose "The Lbi have readed from file '$File'"

            $Value = $Text -replace '^<meta.*?charset=utf-8.*?>'

            if ( -not $SkipUpdateLbiCache ) {
                Write-Verbose "set cache: key='$File'"
                [LibItem]::Cache[$File] = $Value
            }

            $Value
        }
    }
}

<#
.SYNOPSIS
Gets all fragments from an HtmlText.

.DESCRIPTION
It splits an HTMLText into html fragments and library items.

.PARAMETER HtmlText
Whole html text.

.PARAMETER BaseDir
Base directory for library files.
The default location is the current directory.

.EXAMPLE
Get-Content example.html -raw | Get-HtmlFragment
#>
function Get-HtmlFragment {
    [CmdletBinding()]
    [OutputType([HtmlFragment])]
    Param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$HtmlText,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$BaseDir = (Get-Location)
    )

    process {
        $HtmlText -split '(<!-- #BeginLibraryItem ".*?" -->[\s\S]*?<!-- #EndLibraryItem -->)' | ForEach-Object {
            if ( $_ -match '^(?<Begin><!-- #BeginLibraryItem "(?<filename>.*?)" -->)(?<Value>[\s\S]*?)(?<End><!-- #EndLibraryItem -->)$' ) {
                $File = Get-ChildItem (Join-Path -Path $BaseDir -ChildPath $Matches['filename']) | Select-Object -First 1
                [LibItem]::New($Matches['Value'], $File, $Matches['Begin'], $Matches['End'])
            }
            elseif ( $_ ) {
                [HtmlFragment]::New($_)
            }
        }
    }
}

<#
.SYNOPSIS
Update html-fragments.

.PARAMETER Fragment
[HtmlFragment] or derived [LibItems] objects

.PARAMETER UseCachedLbiOnly
Use early cached library items only. If the switch enabled and a lbi is not found in the cache, cmdlet return the original framgent.
#>
function Update-HtmlFragment {
    [CmdletBinding()]
    [OutputType([HtmlFragment])]
    Param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [HtmlFragment]$Fragment,

        [switch]$UseCachedLbiOnly
    )

    process {
        $Fragment.Update($UseCachedLbiOnly)
    }
}

<#
.SYNOPSIS
Merge all fragments. It indents LibItems by a last line in previous html fragment.

.PARAMETER Fragments
[HtmlFragment] and [LibItem]
#>
function Merge-HtmlFragment {
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
            if ($Fragment) {
                [void]$Html.Append($Fragment.Text($IdentStr))
                $IdentStr = $Fragment.LastLineIndent($IdentStr)
            }
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
A literal path to html file.

.PARAMETER BaseDir
A Base directory for library files.
The default location is the current directory.

.PARAMETER Force
Forces the set-content to set the contents of a file, even if the file is read-only.

.PARAMETER UseCachedLbiOnly
Use early cached library items only. If the switch enabled and a lbi is not found in the cache, cmdlet uses the original framgent.

.LINK
set-content
#>
function Update-LibItems {
    [cmdletbinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]]$LiteralPath,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$BaseDir = (Get-Location),

        [switch]$Force,

        [switch]$UseCachedLbiOnly
    )

    process {
        foreach($File in $LiteralPath) {
            Write-Output "BaseDir='$BaseDir'. Upate all Lbi in file '$File'"
            Write-Verbose "UseCachedLbiOnly=$UseCachedLbiOnly"
            Write-Verbose "Force=$Force"

            try {
                $Html = Get-Content -LiteralPath $File -Encoding UTF8 -Raw |
                    Get-HtmlFragment -BaseDir $BaseDir |
                    Update-HtmlFragment -UseCachedLbiOnly:$UseCachedLbiOnly |
                    Merge-HtmlFragment

                $Html | Out-File -FilePath $File -Encoding UTF8 -NoNewline -Force:$Force
            }
            catch {
                Write-Error $Error[0]
            }
        }
    }
}

<#
.SYNOPSIS
Read lbi and store it to lbi cache.

.PARAMETER Path
Specifies a path to the site root.
Wildcards are permitted. The default path is all lbi-files in the Library subdirectory of the current directory.

.PARAMETER Include
Gets only the specified items. The value of this parameter qualifies the -Path parameter. Enter a path element or pattern, such as '*.lbi'.
Wildcards are permitted. The default value is '*.lbi'

.PARAMETER Exclude
Omits the specified items. The value of this parameter qualifies the -Path parameter.
Wildcards are permitted.

.PARAMETER BaseDir
Base directory for library files.
The default location is the current directory.

.PARAMETER Recurse
Gets the files in the specified path and in all child directory.

#>
function Read-Lbi {
    [cmdletbinding()]
    param(
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [String[]]$Path = (Join-Path (Get-Location) '/Library/*'),
        [String[]]$Include = '*.lbi',
        [String[]]$Exclude,
        [switch]$Recurse
    )

    process {
        Write-Verbose "Read Dreamveawer library items (Lbi) and save it to lbi cache."
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

        Get-ChildItem $Path -Include $Include -Exclude $Exclude -Recurse:$Recurse |
            Read-LibItem | Out-Null
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

.PARAMETER UseCachedLbiOnly
Use early cached library items only. If the switch enabled and a lbi is not found in the cache, cmdlet uses the original framgent.

.PARAMETER SkipResetLbiCache
Do not reset library item cache - the Update-LibItems cmdlets should read lbi-files once again.

.LINK
set-content
#>
function Update-Lbi {
    [cmdletbinding()]
    param(
        [Parameter(ValueFromPipeline = $true, Position = 0)]
        [String[]]$Path = (Join-Path (Get-Location) '/*'),
        [String[]]$Include = @('*.html', '*.htm'),
        [String[]]$Exclude,
        [String]$BaseDir = (Get-Location),
        [switch]$Recurse,
        [switch]$Force,
        [switch]$UseCachedLbiOnly,
        [switch]$SkipResetLbiCache
    )

    process {
        if ( $UseCachedLbiOnly ) {
            $SkipResetLbiCache = $true
        }

        Write-Verbose "Update Dreamveawer library items (Lbi) in files."
        Write-Verbose "Path=$Path"
        Write-Verbose "Include=$Include"
        Write-Verbose "Exclude=$Exclude"
        Write-Verbose "BaseDir=$BaseDir"
        Write-Verbose "Recurse=$Recurse"
        Write-Verbose "Force=$Force"
        Write-Verbose "UseCachedLbiOnly=$UseCachedLbiOnly"
        Write-Verbose "SkipResetLbiCache=$SkipResetLbiCache"

        # TODO is it more effective with a parallel updating?
        # see native 'foreach -parallel' and
        # https://github.com/RamblingCookieMonster/Invoke-Parallel
        # https://github.com/powercode/PSParallel

        # TODO add progress bar
        # https://github.com/mazzy-ax/Write-ProgressEx

        Reset-LbiCache -SkipIt:$SkipResetLbiCache | ForEach-Object {
            Get-ChildItem $Path -Include $Include -Exclude $Exclude -Recurse:$Recurse |
                Update-LibItems -BaseDir $BaseDir -UseCachedLbiOnly:$UseCachedLbiOnly
        }
    }
}
