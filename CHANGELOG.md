# Changelog

[![SemVer 2.0.0][📌semver-img]][📌semver] [![Keep-A-Changelog 1.0.0][📗keep-changelog-img]][📗keep-changelog]

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][📗keep-changelog],
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html),
and [yes][📌major-versions-not-sacred], platform and engine support are part of the [public API][📌semver-breaking].
Please file a bug if you notice a violation of semantic versioning.

[📌semver]: https://semver.org/spec/v2.0.0.html
[📌semver-img]: https://img.shields.io/badge/semver-2.0.0-FFDD67.svg?style=flat
[📌semver-breaking]: https://github.com/semver/semver/issues/716#issuecomment-869336139
[📌major-versions-not-sacred]: https://tom.preston-werner.com/2022/05/23/major-version-numbers-are-not-sacred.html
[📗keep-changelog]: https://keepachangelog.com/en/1.0.0/
[📗keep-changelog-img]: https://img.shields.io/badge/keep--a--changelog-1.0.0-FFDD67.svg?style=flat

## [Unreleased]

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [0.1.0] - 2026-06-11

- TAG: [v0.1.0][0.1.0t]
- COVERAGE: 100.00% -- 107/107 lines in 2 files
- BRANCH COVERAGE: 100.00% -- 18/18 branches in 2 files
- 37.21% documented
- Initial release

### Added

- Added a `GemMine::Scaffold` API and `GemMine.scaffold` helper for creating,
  building, installing, git-initializing, and cleaning up minimal fixture gems.

### Changed

- Retemplated with the current kettle-jem template set, adding modern project
  automation, metadata, CI, modular Gemfiles, and template configuration.

### Fixed

- Corrected generated repository metadata and documentation links to use the
  `appraisal-rb/gem_mine` repository owner.
- Corrected generated fixture gem defaults to avoid Thoughtbot repository and
  git author metadata.
- Corrected the gemspec public author email to use `floss@galtzo.com`.

[Unreleased]: https://github.com/appraisal-rb/gem_mine/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/appraisal-rb/gem_mine/compare/ee8f9f471c0f1aa5bdb950b17de9f07cdcd25402...v0.1.0
[0.1.0t]: https://github.com/appraisal-rb/gem_mine/releases/tag/v0.1.0
