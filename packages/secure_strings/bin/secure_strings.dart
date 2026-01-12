// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
// ignore: depend_on_referenced_packages
import 'package:secure_strings/secure_encryption.dart';
import 'package:yaml/yaml.dart';

const String _packageName = "secure_strings";
const String _defaultOutputDir = 'lib/$_packageName';
const String _helperFileName = 'secure_encryption_gr.dart';
const String _keyFileName = '.secure_key';

void main(List<String> args) async {
  try {
    print("🔒 Secure Strings Starting...");

    // 1. Resolve Key from CLI
    int? forcedKey;
    for (final String arg in args) {
      if (arg.startsWith('--key=')) {
        forcedKey = int.tryParse(arg.split('=')[1]);
      }
    }

    // 2. Load Config
    final Map<String, dynamic> config = _loadConfig();
    final String outputDir =
        (config['output_dir'] ?? _defaultOutputDir) as String;

    final Directory dir = Directory(outputDir);
    if (!dir.existsSync()) dir.createSync(recursive: true);

    // 3. Setup Environment
    _ensureGitignore(outputDir);
    final int key = _resolveKey(config, forcedKey, outputDir);
    _generateHelperClass(outputDir, key);

    // 4. Find all *_strings.json files
    final List<FileSystemEntity> entities = dir.listSync();
    final List<File> jsonFiles = entities
        .whereType<File>()
        .where((File file) => file.path.endsWith('_strings.json'))
        .toList();

    if (jsonFiles.isEmpty) {
      print(
          "⚠️  No files matching '*_strings.json' found in $outputDir. Skipping generation.");
      return;
    }

    for (final File jsonFile in jsonFiles) {
      final String fileName =
          p.basenameWithoutExtension(jsonFile.path); // e.g. firebase_strings

      // Convert snake_case to PascalCase for the class name
      final String className = fileName
          .split('_')
          .map((String word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}')
          .join();

      final String genFileName = '${fileName}_gr.dart';
      await _processSingleJsonFile(
          jsonFile, className, outputDir, genFileName, key);
    }

    print("✅ Generation complete for ${jsonFiles.length} files.");
  } catch (e, stack) {
    print("💥 Fatal Error: $e");
    print(stack);
  }
}

Future<void> _processSingleJsonFile(
  File jsonFile,
  String className,
  String outputDir,
  String genFileName,
  int key,
) async {
  final String jsonContent = await jsonFile.readAsString();
  if (jsonContent.trim().isEmpty) return;

  Map<String, dynamic> data;
  try {
    data = Map<String, dynamic>.from(
        jsonDecode(jsonContent) as Map<String, dynamic>);
  } catch (e) {
    print("❌ Error: Failed to parse ${jsonFile.path}. Skipping.");
    return;
  }

  final StringBuffer mainBuffer = StringBuffer();
  final List<String> extraClasses = <String>[];

  mainBuffer.writeln("// GENERATED CODE - DO NOT MODIFY BY HAND");
  mainBuffer.writeln(
      "// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names, always_specify_types");
  mainBuffer.writeln("import '$_helperFileName';");
  mainBuffer.writeln("");
  mainBuffer.writeln("class $className {");

  _processJsonLevel(data, mainBuffer, extraClasses, key, path: className);

  mainBuffer.writeln("}");
  mainBuffer.writeln("");

  for (final String subClass in extraClasses) {
    mainBuffer.writeln(subClass);
  }

  final File dartFile = File(p.join(outputDir, genFileName));
  await dartFile.writeAsString(mainBuffer.toString());
  print("✨ Generated $className -> ${dartFile.path}");
}

void _processJsonLevel(
  Map<String, dynamic> data,
  StringBuffer buffer,
  List<String> extraClasses,
  int key, {
  required String path,
  bool isRoot = true,
}) {
  final List<String> stringsAtThisLevel = <String>[];
  final Map<String, dynamic> subCategories = <String, dynamic>{};

  data.forEach((String element, dynamic value) {
    if (value is String) {
      stringsAtThisLevel.add(element);
    } else if (value is Map<String, dynamic> && element.startsWith('@')) {
      subCategories[element] = value;
    }
  });

  if (stringsAtThisLevel.isNotEmpty) {
    final String valuesClassName = "_${path}Values";
    final String modifier = isRoot ? 'static final' : 'final';
    buffer.writeln('  $modifier values = $valuesClassName();');

    final StringBuffer valuesBuffer = StringBuffer();
    valuesBuffer.writeln('class $valuesClassName {');
    valuesBuffer.writeln('  $valuesClassName();');

    for (final String element in stringsAtThisLevel) {
      final String rawValue = data[element] as String;
      final String encrypted = SecureEncryption.encode(rawValue, key);
      valuesBuffer.writeln(
          '  final String $element = SecureEncryption.decode("$encrypted"); // $rawValue');
    }
    valuesBuffer.writeln('}');
    extraClasses.add(valuesBuffer.toString());
  }

  subCategories.forEach((String element, dynamic value) {
    final String categoryName = element.substring(1);
    final String subPath = "$path$categoryName";
    final String modifier = isRoot ? 'static final' : 'final';

    buffer.writeln('  $modifier $categoryName = _${subPath}Category();');

    final StringBuffer catBuffer = StringBuffer();
    catBuffer.writeln('class _${subPath}Category {');
    catBuffer.writeln('  _${subPath}Category();');

    _processJsonLevel(
      Map<String, dynamic>.from(value as Map<dynamic, dynamic>),
      catBuffer,
      extraClasses,
      key,
      isRoot: false,
      path: subPath,
    );

    catBuffer.writeln('}');
    extraClasses.add(catBuffer.toString());
  });
}

// --- HELPER FUNCTIONS ---

int _resolveKey(Map<String, dynamic> config, int? forcedKey, String outputDir) {
  if (forcedKey != null) return forcedKey;

  final File keyFile = File(p.join(outputDir, _keyFileName));
  if (keyFile.existsSync()) {
    final String content = keyFile.readAsStringSync().trim();
    final String? found = RegExp(r'(\d+)').firstMatch(content)?.group(1);
    if (found != null) return int.parse(found);
  }

  final int newKey = Random().nextInt(899999999) + 100000000;
  keyFile.writeAsStringSync("key=$newKey");
  return newKey;
}

void _ensureGitignore(String outputDir) {
  final File file = File(p.join(outputDir, ".gitignore"));
  const String content =
      "# Ignore generated security files\n$_keyFileName\n*_gr.dart";

  if (!file.existsSync()) {
    file.writeAsStringSync(content);
  } else {
    final String current = file.readAsStringSync();
    if (!current.contains(_keyFileName)) {
      file.writeAsStringSync('\n$content', mode: FileMode.append);
    }
  }
}

Map<String, dynamic> _loadConfig() {
  final File file = File('pubspec.yaml');
  if (!file.existsSync()) return <String, dynamic>{};
  final dynamic yaml = loadYaml(file.readAsStringSync());
  if (yaml == null || yaml[_packageName] == null) return <String, dynamic>{};
  return Map<String, dynamic>.from(yaml[_packageName] as YamlMap);
}

void _generateHelperClass(String outputDirPath, int key) {
  final File file = File(p.join(outputDirPath, _helperFileName));
  file.writeAsStringSync('''
// AUTO-GENERATED BY $_packageName. DO NOT EDIT.
import 'dart:convert';
import 'dart:typed_data';

class SecureEncryption {
  static const int _key = $key;
  static const int _byteKey = _key & 0xFF;

  static String decode(String encodedBase64) {
    try {
      final Uint8List bytes = base64.decode(encodedBase64);
      final List<int> decoded = bytes.map((int b) => b ^ _byteKey).toList();
      return utf8.decode(decoded);
    } catch (e) {
      return encodedBase64;
    }
  }
}
''');
}
