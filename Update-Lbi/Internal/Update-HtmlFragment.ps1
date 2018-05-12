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
