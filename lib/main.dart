import 'package:flutter/material.dart';
import 'package:openbank_mobile/app/app_dependencies.dart';
import 'package:openbank_mobile/app/openbank_theme.dart';
import 'package:openbank_mobile/features/accounts/presentation/dashboard_page.dart';
import 'package:openbank_mobile/features/authentication/presentation/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OpenBankApp());
}

class OpenBankApp extends StatefulWidget {
  const OpenBankApp({super.key, this.dependencies});

  final AppDependencies? dependencies;

  @override
  State<OpenBankApp> createState() => _OpenBankAppState();
}

class _OpenBankAppState extends State<OpenBankApp> {
  late final AppDependencies _dependencies;
  late final bool _ownsDependencies;
  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    _ownsDependencies = widget.dependencies == null;
    _dependencies = widget.dependencies ?? AppDependencies.standard();
  }

  @override
  void dispose() {
    if (_ownsDependencies) _dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenBank',
      debugShowCheckedModeBanner: false,
      theme: OpenBankTheme.light,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _authenticated
            ? DashboardPage(
                key: const ValueKey('dashboard'),
                loadDashboard: _dependencies.loadDashboard,
                loadTransactions: _dependencies.loadTransactions,
                createTransfer: _dependencies.createTransfer,
                signOut: _dependencies.signOut,
                onSignedOut: () => setState(() => _authenticated = false),
              )
            : LoginPage(
                key: const ValueKey('login'),
                signIn: _dependencies.signIn,
                onSignedIn: () => setState(() => _authenticated = true),
              ),
      ),
    );
  }
}
