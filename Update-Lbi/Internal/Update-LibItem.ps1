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
Use early cached library items only. If the switch enabled and a lbi is not found in the cache, function uses the original framgent.

.LINK
set-content
#>
function Update-LibItem {
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
                $HtmlSource = Get-Content -LiteralPath $File -Encoding UTF8 -Raw
                $HtmlResult = $HtmlSource |
                    Get-HtmlFragment -BaseDir $BaseDir |
                    Update-HtmlFragment -UseCachedLbiOnly:$UseCachedLbiOnly |
                    Merge-HtmlFragment

                if ( $HtmlSource -cne $HtmlResult ) {
                    $HtmlResult | Out-File -FilePath $File -Encoding UTF8 -NoNewline -Force:$Force
                }
            }
            catch {
                Write-Error $Error[0]
            }
        }
    }
}
