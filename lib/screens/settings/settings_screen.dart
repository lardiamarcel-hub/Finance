import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_repository.dart';
import '../../utils/app_theme.dart';
import '../onboarding/company_setup_screen.dart';
import 'help_screen.dart';

/// Paramètres : fiche entreprise, langue, aide. Peu d'options, gros
/// libellés, pas de menus imbriqués.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final company = context.watch<AppRepository>().company;

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SettingsTile(
            icon: Icons.storefront_rounded,
            title: 'Fiche entreprise',
            subtitle: company.name.isEmpty ? 'À compléter' : company.name,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CompanySetupScreen(isEditing: true)),
            ),
          ),
          const SizedBox(height: 12),
          const _SettingsTile(
            icon: Icons.language_rounded,
            title: 'Langue',
            subtitle: 'Français',
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.help_rounded,
            title: 'Aide',
            subtitle: 'Comment utiliser l\'application',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HelpScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.orangeDark),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(subtitle, style: const TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
