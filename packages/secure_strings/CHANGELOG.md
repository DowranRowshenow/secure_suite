# Changelog

## [1.0.8] - 2026-01-12

### Added

- **Multiple Strings Json**: Support for json files seperations like `*_strings.json`. For example secure_strings.json will be generated as SecureStrings class.
- **Hierarchical Namespacing**: Support for nested categories using the `@` prefix in `*_strings.json`. Access your strings via `SecureStrings.Category.values.key`.
- **Values Separation**: Introduced the `.values` layer to separate category navigation from string retrieval, significantly cleaning up IDE autocomplete suggestions.
- **Recursive Generator**: The engine now supports infinite levels of nesting (e.g., `SecureStrings.Firebase.Auth.values.token`).

## [1.0.6] - 2026-01-10

### Added

- **Public SecureStrings Class**: Now other packaged or projects depending on this package can get public variables to implement their logic

## [1.0.4] - 2026-01-10

### Added

- **Persistent Key Logic**: Implemented `.secure_key` file persistence in the output directory. It automatically reads `key=12345` format to maintain consistency across runs.
- **Automated Git Protection**: The tool now automatically generates a `.gitignore` inside the `output_dir` to shield the `.secure_key` and generated `.dart` files from being committed.
- **Improved Workspace Setup**: New developers cloning the project now get an immediate visual cue (via the auto-created ignore) on how the security suite manages local files.

### Refactored

- **Dynamic Package Resolution**: Replaced hardcoded strings with a centralized package identity constant to improve maintainability and support suite-wide consistency.
- **Enhanced Documentation**: Updated auto-generated headers to dynamically reference the package name.

### Changed

- **Key Resolution Hierarchy**: Updated priority to: Command Line Argument > Local `.secure_key` File > Pubspec > Random Generation.
- **Directory Safety**: Added automatic recursive directory creation before key persistence or helper generation.

## [1.0.2] - 2026-01-10

### Added

- **Master-Slave Sync**: Added support for the `--key=` CLI argument, allowing `secure_localizations` to act as the master and enforce a specific key.
- **Shared Encoder Integration**: Switched to the internal `SecureEncoder` from the core logic package for build-time operations.

## [1.0.0] - 2026-01-10

Initial stable release. Efficiently obfuscates string constants for Flutter and Dart applications.

### Added

- **Core Encryption Engine**: XOR-based encryption with Base64 encoding.
- **Auto-Generation**: Automatic generation of `SecureStrings` class and `SecureEncryption` helper.
- **Validation**: Added manual check for duplicate keys in `strings.json`.
- **Safety Checks**: Validation for non-string values and empty file detection.
- **Configurability**: Custom key, input, and output paths via `pubspec.yaml`.
