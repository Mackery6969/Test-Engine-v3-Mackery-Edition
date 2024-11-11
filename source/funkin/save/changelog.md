# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

# Test Engine

## [2.3.0] - 2024-08-11

### Added

- 'options.quality:String' to 'Save'
- 'options.uiSkin:String' to 'Save'
- 'seenFlashingScreen:Bool' to 'Save'

## [2.2.0] - 2024-08-02

### Added

- 'options.instrumentalSelect:Bool' to 'Save'
- 'options.songLaunchScreen:Bool' to 'Save'

## [2.1.1] - 2024-07-24

### Changed

- Default Controls modified to be DFJK in 'Save'

## [2.1.0] - 2024-07-22

### Added

- 'options.ghostTapping:Bool' to 'Save'

# Friday Night Funkin'

NOTE: Dates seem to be funky.. that is not my problem though.

## [2.0.6] - 2024-09-12

Note to self: Only update to 2.1.0 when migration is needed.

### Added

- `unlocks.charactersSeen:Array<String>` to `Save`
- `unlocks.oldChar:Bool` to `Save`

## [2.0.5] - 2024-05-21

### Fixed

- Resolved an issue where HTML5 wouldn't store the semantic version properly,
  causing the game to fail to load the save.

## [2.0.4] - 2024-05-21

### Added

- `favoriteSongs:Array<String>` to `Save`

## [2.0.3] - 2024-01-09

### Added

- `inputOffset:Float` to `SongDataOptions`
- `audioVisualOffset:Float` to `SongDataOptions`
