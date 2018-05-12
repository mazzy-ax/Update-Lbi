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

[cmdletbinding()]
param()
Write-Verbose $PSScriptRoot

$functionFolders = @('classes', 'internal', 'functions')
ForEach ($folder in $functionFolders)
{
    $folderPath = Join-Path -Path $PSScriptRoot -ChildPath $folder
    If (Test-Path -Path $folderPath)
    {
        Write-Verbose -Message "Importing from $folder"
        $scripts = Get-ChildItem -Path $folderPath -Filter *.ps1


        $scripts | where-Object { $_.name -NotLike '*.Tests.ps1'} | ForEach-Object {
            Write-Verbose -Message "  Importing $_.basename"
            . $_.FullName
        }
    }
}

$publicFunctions = (Get-ChildItem -Path "$PSScriptRoot\functions\*.ps1").baseName
Export-ModuleMember -Function $publicFunctions