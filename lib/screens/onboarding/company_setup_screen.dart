import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/app_repository.dart';
import '../../models/company.dart';
import '../../utils/app_theme.dart';
import '../home/home_screen.dart';

/// Configuration de l'entreprise. Utilisé une seule fois à la première
/// ouverture, et depuis Paramètres pour modifier la fiche plus tard. Ces
/// informations apparaissent automatiquement sur chaque devis/facture.
class CompanySetupScreen extends StatefulWidget {
  final bool isEditing;

  const CompanySetupScreen({super.key, this.isEditing = false});

  @override
  State<CompanySetupScreen> createState() => _CompanySetupScreenState();
}

class _CompanySetupScreenState extends State<CompanySetupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final company = context.read<AppRepository>().company;
      _nameController.text = company.name;
      _phoneController.text = company.phone;
      _cityController.text = company.city;
      _logoPath = company.logoPath;
    }
  }

  Future<void> _pickLogo() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        imageQuality: 80,
      );
      if (picked != null) setState(() => _logoPath = picked.path);
    } catch (_) {
      // Pas de caméra disponible (ex: émulateur) : on ignore simplement.
    }
  }

  Future<void> _save() async {
    final repo = context.read<AppRepository>();
    await repo.setCompany(
      Company(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        logoPath: _logoPath,
      ),
    );
    if (!mounted) return;
    if (widget.isEditing) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _nameController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Ton commerce')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickLogo,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.orange.withOpacity(0.12),
                  backgroundImage: _logoPath != null ? FileImage(File(_logoPath!)) : null,
                  child: _logoPath == null
                      ? const Icon(Icons.add_a_photo_rounded, size: 32, color: AppColors.orangeDark)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text('Logo ou photo (optionnel)', style: TextStyle(color: AppColors.textMuted)),
            ),
            const SizedBox(height: 28),
            const Text('Nom de ton commerce', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(hintText: 'Ex : Boutique Awa'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            const Text('Numéro de téléphone', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(hintText: '70 00 00 00'),
            ),
            const SizedBox(height: 20),
            const Text('Ville / quartier', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _cityController,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(hintText: 'Ex : Ouagadougou, Dassasgho'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: canSave ? _save : null,
              child: Text(widget.isEditing ? 'Enregistrer' : 'Continuer'),
            ),
          ],
        ),
      ),
    );
  }
}
