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
