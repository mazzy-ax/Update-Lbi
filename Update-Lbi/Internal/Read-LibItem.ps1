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
            $Text = Get-Content -LiteralPath $File -Encoding UTF8 -Raw
            Write-Verbose "The Lbi have readed from the file '$File'"

            $Value = $Text -replace '^<meta.*?charset=utf-8.*?>'

            if ( -not $SkipUpdateLbiCache ) {
                Write-Verbose "set cache: key='$File'"
                [LibItem]::Cache[$File] = $Value
            }

            $Value
        }
    }
}
