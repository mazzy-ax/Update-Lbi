mazzy@mazzy.ru, 2017-10-01, [https://github.com/mazzy-ax/Update-Lbi](https://github.com/mazzy-ax/Update-Lbi)

# Changelog

All notable changes to this project will be documented in this file.

## [v0.3.0] - 2017-10-01

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

## [v0.2.0] - 2017-09-28

A reset cache functionality:

* The Reset-LibItemCache cmdlet added
* The main client cmdlet renamed to Update-Lbi
* The Update-Lbi cmdlet uses Reset-LibItemCache
* The parameter SkipResetLibItemCache added to the Update-Lbi cmdlet
* README.md updated
* The test data updated

## [v0.1.0] - 2017-09-24

Initial version

[v0.2.0]: https://github.com/mazzy-ax/Update-Lbi/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/mazzy-ax/Update-Lbi/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/mazzy-ax/Update-Lbi/compare/v0.1.0...v0.1.0
