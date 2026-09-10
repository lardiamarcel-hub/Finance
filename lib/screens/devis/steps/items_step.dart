import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/app_repository.dart';
import '../../../models/devis_item.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/money_text.dart';
import '../../../widgets/quantity_stepper.dart';

/// Étape 2 : ajouter des articles depuis le catalogue (ou en créer un
/// nouveau à la volée), avec quantité par boutons +/- et total en direct.
class ItemsStep extends StatelessWidget {
  final List<DevisItem> items;
  final ValueChanged<DevisItem> onAddOrUpdate;
  final ValueChanged<String> onRemove;

  const ItemsStep({
    super.key,
    required this.items,
    required this.onAddOrUpdate,
    required this.onRemove,
  });

  double get _total => items.fold(0, (sum, i) => sum + i.total);

  Future<void> _openAddProductSheet(BuildContext context) async {
    final repo = context.read<AppRepository>();
    final products = repo.productsSortedByName;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Ajouter un article',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            final existing = items.where((i) => i.productId == product.id);
                            final quantity = existing.isEmpty ? 1 : existing.first.quantity + 1;
                            onAddOrUpdate(DevisItem(
                              productId: product.id,
                              productName: product.name,
                              unitPrice: product.price,
                              quantity: quantity,
                            ));
                            Navigator.of(sheetContext).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                MoneyText(amount: product.price, fontSize: 16),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _openNewProductSheet(context);
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Nouveau produit ou service'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
                  final product = await repo.addProduct(name: name, price: price);
                  onAddOrUpdate(DevisItem(
                    productId: product.id,
                    productName: product.name,
                    unitPrice: product.price,
                    quantity: 1,
                  ));
                  if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                },
                child: const Text('Ajouter au devis'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: OutlinedButton.icon(
            onPressed: () => _openAddProductSheet(context),
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: const Text('Ajouter un article'),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const _EmptyItems()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => onRemove(item.productId),
                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              QuantityStepper(
                                value: item.quantity,
                                onChanged: (q) => onAddOrUpdate(item.copyWith(quantity: q)),
                              ),
                              MoneyText(amount: item.total, fontSize: 18),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: AppColors.orange.withOpacity(0.08),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              MoneyText(amount: _total, fontSize: 26),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyItems extends StatelessWidget {
  const _EmptyItems();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 56, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              'Aucun article ajouté.\nTouche "Ajouter un article".',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
