import 'dart:convert';
import 'dart:typed_data';

/// Common logic to encrypt strings using XOR.
/// This file is used only during build time.
class SecureEncryption {
  static const int _salt = 0xFF;

  static String encode(String plainText, int key) {
    final int byteKey = key & _salt;
    final Uint8List bytes = utf8.encode(plainText);
    final List<int> xor = bytes.map((int b) => b ^ byteKey).toList();
    return base64.encode(Uint8List.fromList(xor));
  }

  static String decode(String encodedBase64, int key) {
    final int byteKey = key & _salt;
    final Uint8List bytes = base64.decode(encodedBase64);
    final List<int> decoded = bytes.map((int b) => b ^ byteKey).toList();
    return utf8.decode(decoded);
  }
}
