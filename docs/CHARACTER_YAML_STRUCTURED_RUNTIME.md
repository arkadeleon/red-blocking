# RedBlocking Structured Character YAML Runtime

## Status

- Recorded on: 2026-03-16
- Runtime source of truth: `RedBlocking/Resources/CharacterData/*.yml`
- Active runtime path: structured `CharacterProfile`

## Runtime Flow

1. `CharacterRepository` decodes `Characters.yml` into the roster used by `CharacterListModel`.
2. `AppNavigationModel` loads the selected move file through `MoveRepository.loadProfile(resourceName:)`.
3. `MoveRepository` decodes the character move file directly into `CharacterProfile`.
4. `MoveBrowserProjector` projects `CharacterProfile` and nested `MoveEntry` values into `MoveBrowserPage`.
5. `MoveBrowserModel` and `MoveBrowserView` render the projected sections and rows.
6. `MoveMedia` drives motion player navigation through `MoveBrowserAction.MotionPlayerLink`.

The app no longer decodes character move files through the legacy `CharacterMove.Section` tree.

## Retained Regression Assets

- Baseline report: `docs/CHARACTER_YAML_PHASE0_BASELINE.md`
- Legacy browser snapshots: `docs/character_yaml_legacy_browser_snapshots/`
- Structured schema spec: `docs/CHARACTER_YAML_STRUCTURED_SCHEMA.md`
- Migration script: `scripts/character_yaml_phase4_structured_migration.rb`
- Test suites:
  - `RedBlockingTests/CharacterProfileDecodingTests.swift`
  - `RedBlockingTests/MoveBrowserProjectorTests.swift`
  - `RedBlockingTests/MoveEntryValidationTests.swift`
  - `RedBlockingTests/MoveBrowserParityTests.swift`

## Verification Commands

- Build: `xcodebuild build -project RedBlocking.xcodeproj -scheme RedBlocking -destination 'generic/platform=iOS'`
- Test: `xcodebuild test -project RedBlocking.xcodeproj -scheme RedBlocking -destination 'platform=iOS Simulator,OS=26.3.1,name=iPhone 17'`

## Notes

- Legacy snapshots remain in the repository as parity baselines and migration references.
- The migration script remains available for future structured YAML regeneration.
