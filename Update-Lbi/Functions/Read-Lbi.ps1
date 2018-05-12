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
        # https://github.com/nightroman/SplitPipeline
        # https://github.com/RamblingCookieMonster/Invoke-Parallel
        # https://github.com/powercode/PSParallel

        Get-ChildItem $Path -Include $Include -Exclude $Exclude -Recurse:$Recurse |
            Read-LibItem | Out-Null
    }
}
