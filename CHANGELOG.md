# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1]

* Update the version reported by the --version option, as well as the version tag on the repo.

## [1.0.3]

* Use Swift 5.10.0 to build the application
* Change deprecated options, `--original-url` and `--mirror-url` to the preferred `--original` and `--mirror`

## [1.0.2]

* Update parsing for swift-tools-version:5.6
* Perform a `git restore` on each mirror before pulling updates
* Use Ubuntu "jammy" and Swift 5.8 to build the Docker image

## [1.0.1]

### Fixed

* Strip `.git` from mirror name [issue 1](https://github.com/sbeitzel/Mirror-Package/issues/1)

## [1.0.0]

Initial release!

--

[Unreleased]: https://github.com/sbeitzel/Mirror-Package/compare/1.1.1...HEAD
[1.1.1]: https://github.com/sbeitzel/Mirror-Package/compare/1.0.3...1.1.1
[1.0.3]: https://github.com/sbeitzel/Mirror-Package/compare/1.0.2...1.0.3
[1.0.2]: https://github.com/sbeitzel/Mirror-Package/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/sbeitzel/Mirror-Package/compare/1.0.0...1.0.1
[1.0.0]: https://github.com/sbeitzel/Mirror-Package/releases/tag/1.0.0
