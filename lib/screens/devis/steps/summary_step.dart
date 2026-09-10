import 'package:flutter/material.dart';

import '../../../models/devis_item.dart';
import '../../../utils/app_theme.dart';
import '../../../widgets/money_text.dart';
import '../../../widgets/quantity_stepper.dart';

/// Étape 3 : récapitulatif clair, avec possibilité de modifier une ligne
/// (quantité) en un tap, sans revenir en arrière dans le parcours.
class SummaryStep extends StatelessWidget {
  final String clientName;
  final List<DevisItem> items;
  final void Function(DevisItem item, int newQuantity) onEditQuantity;

  const SummaryStep({
    super.key,
    required this.clientName,
    required this.items,
    required this.onEditQuantity,
  });

  double get _total => items.fold(0, (sum, i) => sum + i.total);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              const Icon(Icons.person_rounded, color: AppColors.orangeDark),
              const SizedBox(width: 8),
              Text(
                clientName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          MoneyText(amount: item.total, fontSize: 16),
                        ],
                      ),
                    ),
                    QuantityStepper(
                      value: item.quantity,
                      onChanged: (q) => onEditQuantity(item, q),
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
