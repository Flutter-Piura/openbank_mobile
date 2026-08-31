import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const initialRoute = '/inicio';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenBank',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {initialRoute: (_) => const OpenBankStartPage()},
    );
  }
}

class OpenBankStartPage extends StatelessWidget {
  const OpenBankStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Center(child: Text('OpenBank'))),
    );
  }
}
