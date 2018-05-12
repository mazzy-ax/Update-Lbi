<#
.SYNOPSIS
Reset library item cache. The Update-LibItem cmdlets should read lbi-files once again.

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
