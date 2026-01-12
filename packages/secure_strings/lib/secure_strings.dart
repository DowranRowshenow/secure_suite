class SecureStrings {
  static const String packageName = "secure_strings";
  static const String keyFileName = '.secure_key'; // The local secret file
  static const String defaultOutputDir = 'lib/$packageName';
  static const String inputFileName = 'strings.json';
  static const String helperFileName = 'secure_encryption_gr.dart';
  static const String genFileName = '${packageName}_gr.dart';
}
