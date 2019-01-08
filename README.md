# Update-Lbi

[project]:https://github.com/mazzy-ax/Update-Lbi
[license]:https://github.com/mazzy-ax/Update-Lbi/blob/master/LICENSE
[ps]:https://www.powershellgallery.com/packages/Update-Lbi
[nuget]:https://www.nuget.org/packages/update-lbi
[appveyor]:https://ci.appveyor.com/project/mazzy-ax/update-lbi

[![Build status](https://ci.appveyor.com/api/projects/status/vbma1t98ml2xakcw?svg=true)][appveyor]
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/Update-Lbi.svg)][ps]
[![NuGet](https://buildstats.info/nuget/Update-Lbi)][nuget]
<img src="https://raw.githubusercontent.com/mazzy-ax/Update-Lbi/master/Media/Update-Lbi-icon.png" align="right" alt="Update-Lbi icon">

[Update-Lbi][project] is powershell module with advanced functions updates **Dreamweaver library items** (LBI) within html-files.

LBI-block format:

```html
<!-- #BeginLibraryItem "/Library/filename.lbi" -->
html tags and regular text
<!-- #EndLibraryItem -->
```

The function reads `filename.lbi` and refreshes all content between #BeginLibraryItem and #EndLibraryItem html-comments.

See more about LBI: <https://helpx.adobe.com/dreamweaver/using/library-items.html>

## Examples

Update all html-files in the site root directory and it's subdirectories. The function `Update-Lbi` reinitialize the lbi-cache at each execution.

```powershell
Set-Location %siteRoot%
Update-Lbi -Recurse
```

Update library items with `menu` prefix only in all html-files in the site root directory. `Lbi` with other file names is not change.

```powershell
Set-Location %siteRoot%
Read-Lbi -include 'menu*.lbi'
Update-Lbi -UseCachedItemsOnly
```

Update library items with specified folders. The function `Update-Lbi` reads each `lbi` from file only once.

```powershell
Set-Location %siteRoot%
Reset-LbiCache | % {
    Update-Lbi './Foo/*' -SkipResetLbiCache
    Update-Lbi './Bar/*' -SkipResetLbiCache
}
```

## Installation

Automatic install the module from the [PowerShell Gallery][ps]:

```powershell
Install-Module Update-Lbi
```

Automatic install the module from the [NuGet.org][nuget]:

```powershell
Install-Package Update-Lbi
```

or manual download and unzip the [latest module files](https://github.com/mazzy-ax/Update-Lbi/archive/master.zip) into your `$PSModulePath`. For example `$env:USERPROFILE\Documents\WindowsPowerShell\Modules`. Set an execution policy to `RemoteSigned` or `Unrestricted` to execute not signed modules.

```powershell
Set-ExecutionPolicy RemoteSigned
```

## Known issues

* The function does not read a character encoding from LBI and html-files, it uses UTF-8 encoding anyway.

## Changelog

* [CHANGELOG.md](CHANGELOG.md)
* <https://github.com/mazzy-ax/Update-Lbi/releases>.

## License

This project is released under the [licensed under the MIT License][license].

mazzy@mazzy.ru