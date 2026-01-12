# Secure Strings

A Flutter/Dart tool that hardens your application binaries by encrypting constant strings and decrypting them only at runtime. This prevents sensitive data (API keys, endpoints, secrets) from being visible via `strings` command analysis or hex editors on your compiled `libapp.so`.

## Features

- 🔐 **XOR Encryption**: Encrypts strings at compile-time and stores them as Base64.
- 📂 **Hierarchical Namespacing**: Organize strings into categories using the `@` prefix in JSON.
- 🧠 **Smart Autocomplete**: Separates navigation from retrieval using a `.values` layer.
- 🛡️ **Auto-Git Protection**: Automatically manages `.gitignore` in your output directory to shield secrets and generated code.
- ⚡ **Performance**: Ultra-fast XOR bitwise operations for zero-lag runtime decryption.
- 🔑 **Persistent Key Management**: Automatically generates and stores a local encryption key in `.secure_key`.

## Setup

Add the configuration to your `pubspec.yaml`;

```yaml
secure_strings:
  # Optional: Where the generated Dart files will live (Default: lib/secure_strings)
  output_dir: "lib/secure_strings"

dev_dependencies:
  secure_strings:
    git:
      url: https://github.com/DowranRowshenow/secure_strings.git
      path: packages/secure_strings
      ref: v1.0.8
```

## Usage

1. **Prepare Source**: Create your `*_strings.json` like this `lib/secure_strings/any_name_strings.json`. Use `@` to create categories:

```json
{
  "appName": "Secure App",
  "@Firebase": {
    "apiKey": "AIzaSyD-12345",
    "projectId": "my-app-123",
    "@Auth": {
      "name": "Name"
    }
  }
}
```

2. **Generate**: Run the generator from your project root:

```bash
dart run secure_strings

```

3. **Use**: Import and use the generated class. Notice the `.values` layer for clean autocomplete:

```dart
import 'package:your_app/secure_strings/secure_strings_gr.dart';

void main() {
  // Access root strings
  print(SecureStrings.values.appName);

  // Access nested categories
  print(SecureStrings.Firebase.values.apiKey);
}

```

## Collaboration & Git Safety

To prevent security leaks and merge conflicts, the tool **automatically** manages a `.gitignore` file within your `output_dir`.

**What is ignored:**

- `.secure_key`: Your unique local encryption secret.
- `*_gr.dart`: All generated Dart files.

**New Team Members:** After cloning the repository, simply run `dart run secure_strings`. This will generate the local helpers and keys required for the project to compile.

## How Key Resolution Works

The tool resolves the encryption key in this order:

1. **Command Line**: `--key=12345` (Used for syncing with `secure_localizations`).
2. **Local File**: The value inside `lib/secure_strings/.secure_key`.
3. **Pubspec**: The `key` field in `pubspec.yaml`.
4. **Auto-Generate**: If no key is found, a new random key is saved to `.secure_key`.

## Why use this?

Standard Flutter obfuscation (`--obfuscate`) hides class and method names but **does not** hide hardcoded strings. `secure_strings` ensures that your API endpoints and secrets are stored as non-human-readable data, significantly hardening your binary against reverse engineering.
