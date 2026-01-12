import 'package:flutter/material.dart';

import 'secure_strings/secure_strings_gr.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SecureStrings.values.title)),
      body: Center(
        child: Text(SecureStrings.Login.values.text),
      ),
    );
  }
}
