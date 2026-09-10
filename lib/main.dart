import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/app_repository.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/company_setup_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const DevisSapSapApp());
}

class DevisSapSapApp extends StatelessWidget {
  const DevisSapSapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppRepository()..init(),
      child: MaterialApp(
        title: 'Devis Sap Sap',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        // Le texte du système peut être grossi par l'utilisateur (accessibilité) ;
        // on le laisse faire, l'app est déjà pensée en gros caractères.
        home: const _StartupGate(),
      ),
    );
  }
}

/// Attend que le repository ait fini de charger les données locales
/// (mode hors-ligne) avant d'afficher le premier écran. Pas d'écran de
/// connexion pour l'instant : on va directement à la configuration de
/// l'entreprise (première fois) ou à l'accueil.
class _StartupGate extends StatelessWidget {
  const _StartupGate();

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    if (!repo.isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.orange)),
      );
    }
    return repo.company.isConfigured ? const HomeScreen() : const CompanySetupScreen();
  }
}
