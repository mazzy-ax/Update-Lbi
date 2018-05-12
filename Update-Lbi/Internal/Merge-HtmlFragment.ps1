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
