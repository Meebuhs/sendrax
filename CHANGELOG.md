# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.6.3 - 2021-07-21

### Fixed

- Fixed addition of photos to climbs

## 0.6.2 - 2021-07-21

### Fixed

- Fixed location creation (thanks ben :confetti_ball:)

## 0.6.1 - 2021-07-16

### Added

- Added coloured send type indicators to attempts in climb view

### Changed

- Changed progress indicators to fit app theme

### Fixed

- Fixed logic for disabling Onsight and Flash buttons
- Fixed sizing of dismissible background on attempts in climb view
- Fixed a misplaced full stop on empty charts (thanks pat :tada:)

## 0.6.0 - 2021-07-11

### Added

- Added sent and repeated status to climb views
- Added attempt count to climb views

### Changed

- Changed climb form to use buttons for each send type instead of a dropdown
- Migrate Flutter to 2.2.3, Firebase auth to 2.0.0, Firebase Storage to 9.0.0, Cloud Firestore to 2.3.0

## 0.5.0 - 2020-04-17

### Added

- Added sent and repeated statuses to each climb
- Added sent and repeated filters to location view

### Fixed

- Fixed issue where images were being displayed for climbs without a set image in view only climb 
- Fixed archive section not properly archiving climbs

### Changed

- Migrate ImagePicker API usage to 0.6.7 

## 0.4.0 - 2020-03-02

### Added

- Added category filter to location view
- Added ability to archive an entire section of climbs
- Added fullscreen view on image tap
- Added email sign up 
- Added ability to reset account password

## 0.3.0 - 2020-02-27

### Added

- Added stats view
    - Charts
        - Number of attempts by date
        - Number of attempts by day of week
        - Number of attempts by time of day
        - Number of attempts by grade
        - Average attempts needed to send a grade
        - Average repeats by grade
        - Proportion of climbs downclimbed by grade
        - Number of attempts by location
        - Number of attempts by category
        - Highest and average grade by send type
    - Ability to filter attempts shown in the charts
        - Filter by grade, time, location, send type and category

### Fixed

- Fixed bug where attempts were only being deleted from log view

## 0.2.0 - 2020-02-12

### Added

- Added history view
    - Ability to view all past completed attempts
    - Ability to filter past attempts by grade, location and climb category
    - Lazy loads attempt list in segments that contain full days worth of attempts
    - Tap a climb to view its full attempt history

## 0.1.0 - 2020-02-06

### Added

- Added base functionality of the app
    - Firebase account creation and authentication
    - Ability to create, edit and delete locations and climbs
        - Locations can have a name, an image, a grade set and sections
        - Climbs can have a name, a grade, a section (if they exist in the location) and descriptive categories
    - Ability to log and delete attempts made on a climb
    - Ability to filter the climbs being displayed in a location
    - Ability to archive climbs so they no longer appear in a location's list of climbs
