# Changelog

All notable changes to the [project](https://github.com/mazzy-ax/Update-Lbi) will be documented in this file. See also <https://github.com/mazzy-ax/Update-Lbi/releases>.

## [0.4.0](https://github.com/mazzy-ax/Update-Lbi/compare/v0.3.0...v0.4.0) - 2018-05-12

* The directory structure reorganized to remove media, examples and tests from nuget downloads and powershell gallery
* Cmdlets extracted to separate files
* The list of public cmdlets changed. Public cmdlets are: Update-Lbi, Read-Lbi, Reset-LbiCache. Other cmdlets are internal
* A required version changed from 3.0 to 5.0 because a `class` used
* Project meta info tests added
* The name of the cmdlet `Update-LbiItems` changed to `Update-LbiItem` due psScriptAnalyzer recommendations
* Readme and typo cleared

## [0.3.0] - 2017-10-01

* No changes - No saves. A Html file is not touched if html content is not changed.
* Added:
  * Read-Lbi cmdlet
  * Read-LibItem cmdlet
  * Parameter UseCachedLbiOnly added
* Renamed:
  * Reset-LbiCache from Reset-LibItemCache
  * Get-HtmlFragment from Get-LibItem
  * Update-HtmlFragment from Update-LibItem
  * Merge-HtmlFragment from Merge-LibItem
* Read lbi extracted from the class methot to cmdlet
* Reset-LbiCache work with pipe
* Minor errors fixed

## [0.2.0] - 2017-09-28

A reset cache functionality:

* The Reset-LibItemCache cmdlet added
* The main client cmdlet renamed to Update-Lbi
* The Update-Lbi cmdlet uses Reset-LibItemCache
* The parameter SkipResetLibItemCache added to the Update-Lbi cmdlet
* README.md updated
* The test data updated

## [0.1.0] - 2017-09-24

Initial version

[0.3.0]: https://github.com/mazzy-ax/Update-Lbi/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/mazzy-ax/Update-Lbi/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/mazzy-ax/Update-Lbi/compare/v0.1.0...v0.1.0
