mazzy@mazzy.ru, 2017-09-24, [https://github.com/mazzy-ax/Update-Lbi](https://github.com/mazzy-ax/Update-Lbi)

# Update-Lbi

![version][version-badge] ![license][license-badge]

**Update-Lbi.ps1** is powershell cmdlet updates **Dreamweaver library items** (LBI) within html-files.

LBI-blocks has format:

```html
<!-- #BeginLibraryItem "/Library/filename.lbi" -->
html tags and regular texts
<!-- #EndLibraryItem -->
```

The cmlet read filename.lbi and refresh all content between #BeginLibraryItem and #EndLibraryItem html-comments.

See more about LBI: https://helpx.adobe.com/dreamweaver/using/library-items.html

# Examples

```powershell
Update-LibItemsCli -Path %siteRoot%/*.html
```

# Known issues and ideas for a future development

* The cmdlet does not read a character encoding from LBI and html-files. The cmdlet always use UTF-8 encoding.
* The cmdlet does not use parallel processing. It is one thread application.

# Installation

Automatic install the Update-Lbi cmdlet from the [PowerShell Gallery](https://www.powershellgallery.com/packages/Update-Lbi):

```powershell
Install-Script -Name Update-Lbi
```

Automatic install the Update-Lbi cmdlet from the [NuGet.org](https://www.nuget.org/packages/Update-Lbi):

```powershell
Install-Package Update-Lbi
```

or manual download and unblock the latest script file.

# Changelog

See file [CHANGELOG.md](/CHANGELOG.md)

[version-badge]: https://img.shields.io/badge/version-1.0.0-green.svg
[license-badge]: https://img.shields.io/badge/license-apache--2-blue.svg