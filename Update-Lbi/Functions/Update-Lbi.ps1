<#
.SYNOPSIS
Update lbi in several html files.

.DESCRIPTION
The function provides useful features:
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
Use early cached library items only. If the switch enabled and a lbi is not found in the cache, function uses the original framgent.

.PARAMETER SkipResetLbiCache
Do not reset library item cache - the Update-LibItem function should read lbi-files once again.

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
        # https://github.com/nightroman/SplitPipeline
        # https://github.com/RamblingCookieMonster/Invoke-Parallel
        # https://github.com/powercode/PSParallel

        # TODO add progress bar
        # https://github.com/mazzy-ax/Write-ProgressEx

        Reset-LbiCache -SkipIt:$SkipResetLbiCache | ForEach-Object {
            Get-ChildItem $Path -Include $Include -Exclude $Exclude -Recurse:$Recurse |
                Update-LibItem -BaseDir $BaseDir -UseCachedLbiOnly:$UseCachedLbiOnly
        }
    }
}
