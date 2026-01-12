# Secure Suite 🛡️

A comprehensive security toolkit for Flutter and Dart applications designed to harden binaries against reverse engineering and simplify sensitive data management.

## Packages

This monorepo contains the following core packages:

| Package                                                                                                     | Description                                                                 | Status |
| ----------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------- | ------ |
| **[Secure Strings](https://github.com/DowranRowshenow/secure_strings/packages/secure_strings)**             | Encrypts constant strings (API keys, secrets) and decrypts them at runtime. |        |
| **[Secure Localizations](https://github.com/DowranRowshenow/secure_strings/packages/secure_localizations)** | An encrypted localization engine that secures your translation files.       |        |

---

## Why Secure Suite?

Standard Flutter obfuscation (`--obfuscate`) hides class and method names but leaves your **hardcoded strings and localization assets in plain text**. Anyone using a hex editor or the `strings` command on your `libapp.so` can extract your API endpoints, secrets, and private keys.

**Secure Suite** solves this by:

1. **XOR Encryption**: Moving all sensitive data into an encrypted binary format.
2. **Modular Architecture**: Allowing you to split secrets into feature-based files (e.g., `firebase_strings.json`).
3. **Local Key Management**: Using local `.secure_key` files that never enter your Git history, ensuring that every developer (or CI/CD environment) can maintain unique or synchronized encryption states.

---

## Installation

Since this is a monorepo, you must specify the `path` to the package you wish to use in your `pubspec.yaml`.

### Add Secure Strings

```yaml
dependencies:
  secure_strings:
    git:
      url: https://github.com/DowranRowshenow/secure_suite.git
      path: packages/secure_strings
      ref: v1.0.8
```

### Add Secure Localizations

```yaml
dependencies:
  secure_localizations:
    git:
      url: https://github.com/DowranRowshenow/secure_suite.git
      path: packages/secure_localizations
      ref: main
```

---

## Workspace Architecture

The suite is designed to be **Modular**. Instead of one giant configuration, you create specific JSON files for different domains.

### 📂 Directory Setup

Place your source files in your defined `output_dir` (default: `lib/secure_strings`):

- `firebase_strings.json` → Generates `FirebaseStrings` class.
- `api_keys_strings.json` → Generates `ApiKeysStrings` class.

### 🚀 Quick Start

1. **Generate Keys/Code**: Run the generator for either package:

```bash
dart run secure_strings
dart run secure_localizations

```

2. **Access Data**:

```dart
// Secure Strings
print(FirebaseStrings.values.apiKey);

// Secure Localizations
print(context.secureLoc.welcomeMessage);

```

---

## Collaboration & Security

- **Git Safety**: All packages automatically generate `.gitignore` rules to prevent `.secure_key` and generated `*_gr.dart` files from being committed.
- **Syncing Keys**: If you need to share an encryption key across a team or CI/CD, use the `--key=` argument during generation.

---

## License

This project is licensed under the MIT License - see the individual package folders for details.
