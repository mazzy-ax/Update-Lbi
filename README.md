mazzy@mazzy.ru, 2017-10-01, [https://github.com/mazzy-ax/Update-Lbi](https://github.com/mazzy-ax/Update-Lbi)

![version](https://img.shields.io/badge/version-0.3.0-green.svg) ![license](https://img.shields.io/badge/license-MIT-blue.svg)

---

# Update-Lbi

**Update-Lbi** is powershell cmdlet updates **Dreamweaver library items** (LBI) within html-files.

![icon](/Media/Update-Lbi-icon.png "Update-Lbi")

LBI-block format:

```html
<!-- #BeginLibraryItem "/Library/filename.lbi" -->
html tags and regular texts
<!-- #EndLibraryItem -->
```

The cmlet read filename.lbi and refresh all content between #BeginLibraryItem and #EndLibraryItem html-comments.

See more about LBI: https://helpx.adobe.com/dreamweaver/using/library-items.html

# Examples

Update all html-files in the site root directory and it's subdirectories. The cmdlet reinitialize the lbi-cache at each execution.

```powershell
Set-Location %siteRoot%
Update-Lbi -Recurse
```

Update library items with 'menu' name prefix only in all html-files in the site root directory. Lbi with other file names is not change.

```powershell
Set-Location %siteRoot%
Read-Lbi -include 'menu*.lbi'
Update-Lbi -UseCachedItemsOnly
```

Update library items with specified folders. The cmdlet read each lbi from file only once.

```powershell
Set-Location %siteRoot%
Reset-LbiCache | % {
    Update-Lbi './Foo/*' -SkipResetLbiCache
    Update-Lbi './Bar/*' -SkipResetLbiCache
}
```

# Installation

Automatic install the Update-Lbi cmdlet from the [PowerShell Gallery](https://www.powershellgallery.com/packages/Update-Lbi):

```powershell
Install-Module Update-Lbi
```

Automatic install the Update-Lbi cmdlet from the [NuGet.org](https://www.nuget.org/packages/Update-Lbi):

```powershell
Install-Package Update-Lbi
```

or manual download and unzip the [latest module files](https://github.com/mazzy-ax/Update-Lbi/archive/master.zip) into your $PSModulePath. For example $env:USERPROFILE\Documents\WindowsPowerShell\Modules. Set an execution policy to RemoteSigned or Unrestricted to execute not signed modules.

```powershell
Set-ExecutionPolicy RemoteSigned
```

# Known issues and ideas for a future development

* The cmdlet does not read a character encoding from LBI and html-files. The cmdlet always use UTF-8 encoding.
* The cmdlet does not use parallel processing. It is one thread application.

# Changelog

See file [CHANGELOG.md](/CHANGELOG.md)
