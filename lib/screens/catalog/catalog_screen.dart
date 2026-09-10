import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_repository.dart';
import '../../utils/app_theme.dart';
import '../../widgets/money_text.dart';

/// Catalogue des produits/services habituels, pour ne pas les retaper à
/// chaque devis. Ajout ultra-rapide : nom + prix.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  Future<void> _openNewProductSheet(BuildContext context) async {
    final repo = context.read<AppRepository>();
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nouveau produit / service',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: 'Nom du produit ou service'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                decoration: const InputDecoration(hintText: 'Prix (FCFA)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final price = double.tryParse(priceController.text.trim());
                  if (name.isEmpty || price == null || price <= 0) return;
                  await repo.addProduct(name: name, price: price);
                  if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editPrice(BuildContext context, String productId, double currentPrice) async {
    final repo = context.read<AppRepository>();
    final priceController = TextEditingController(text: currentPrice.round().toString());

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Modifier le prix', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                decoration: const InputDecoration(hintText: 'Prix (FCFA)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final price = double.tryParse(priceController.text.trim());
                  if (price == null || price <= 0) return;
                  final product = repo.products.firstWhere((p) => p.id == productId);
                  await repo.updateProduct(product.copyWith(price: price));
                  if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final products = repo.productsSortedByName;

    return Scaffold(
      appBar: AppBar(title: const Text('Mes produits & services')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.orange,
        onPressed: () => _openNewProductSheet(context),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: products.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Pas encore de produit.\nTouche le bouton + pour en ajouter un.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppColors.textMuted),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final product = products[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _editPrice(context, product.id, product.price),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.inventory_2_rounded, color: AppColors.orangeDark),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                          MoneyText(amount: product.price, fontSize: 17),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
