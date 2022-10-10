# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.4.0] - 2022-10-10

- Added `MoneyCodingKeys` type for more convenient decoding of custom keys.
  #21 by @mattt.

## [1.3.0] - 2021-04-17

### Added

- Added initializer from a currency's minor units.
  #15 by @mattt.
- Added top-level `iso4217Currency(for:)` function.
  #16 by @mattt.

## [1.2.1] - 2020-11-09

### Changed

- Changed Swift versions specified in CocoaPods podspec file.
  #11 by @mattt.

## [1.2.0] - 2019-05-06

### Added

- Added configurable encoding and decoding behavior.
  #9 by @mattt.

## [1.1.1] - 2019-05-11

### Added

- Added support for CocoaPods.
  d51b2f14 by @mattt.

## [1.1.0] - 2019-03-31

### Added

- Added `AdditiveArithmetic` protocol conformance in Swift 5.
  d1bbaf by @mattt.
- Added `CHANGELOG.md`.
  1caec0 by @mattt.
  
### Changed

- Changed Xcode project settings for Xcode 10.2 and Swift 5.
  facb5a4 by @mattt.

## [1.0.2] - 2019-03-31

### Added

- Added `Makefile` to automatically generate `Sources/Money/Currency.swift`.
  3cc0e87 by @mattt.
- Added `Brewfile` to install `gyb` command line tool.
  153cdb by @mattt.

### Changed

- Changed entry for Comorian Franc to remove extra space.
  1ba55a by @mattt.

### Removed

- Removed GYB tools from Vendor directory.
  938db3 by @mattt.

## [1.0.1] - 2018-07-03

### Added

- Added support for installation with Carthage.
  ed42a0 by @mattt.

## [1.0.0] - 2018-06-26

- Initial release

[unreleased]: https://github.com/SwiftDocOrg/doctest/compare/1.4.0...main
[1.3.0]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.4.0
[1.3.0]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.3.0
[1.2.1]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.2.1
[1.2.0]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.2.0
[1.1.1]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.1.1
[1.1.0]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.1.0
[1.0.2]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.0.2
[1.0.1]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.0.1
[1.0.0]: https://github.com/SwiftDocOrg/swift-doc/releases/tag/1.0.0
