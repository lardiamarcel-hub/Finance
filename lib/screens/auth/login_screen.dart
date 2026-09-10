import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_repository.dart';
import '../../utils/app_theme.dart';
import '../home/home_screen.dart';
import '../onboarding/company_setup_screen.dart';

/// Connexion par numéro de téléphone + code SMS : plus familier qu'un
/// email/mot de passe pour le public visé.
///
/// Note : ici la vérification est simulée (n'importe quel code à 4 chiffres
/// est accepté). Le vrai envoi/vérification SMS sera branché avec Firebase
/// Auth à la toute fin du projet, sans changer cet écran.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSent = false;

  void _continueAfterLogin() {
    final repo = context.read<AppRepository>();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => repo.company.isConfigured
            ? const HomeScreen()
            : const CompanySetupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.receipt_long_rounded, size: 72, color: AppColors.orange),
              const SizedBox(height: 12),
              const Text(
                'Devis Sap Sap',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Fais ton devis, vite fait.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textMuted),
              ),
              const SizedBox(height: 40),
              if (!_codeSent) ...[
                const Text('Ton numéro de téléphone', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(hintText: '70 00 00 00'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _phoneController.text.trim().isEmpty
                      ? null
                      : () => setState(() => _codeSent = true),
                  child: const Text('Recevoir le code'),
                ),
              ] else ...[
                Text(
                  'Entre le code reçu par SMS au ${_phoneController.text}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26, letterSpacing: 8),
                  decoration: const InputDecoration(hintText: '••••'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _codeController.text.trim().isEmpty ? null : _continueAfterLogin,
                  child: const Text('Valider'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _codeSent = false),
                  child: const Text('Changer de numéro'),
                ),
              ],
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
