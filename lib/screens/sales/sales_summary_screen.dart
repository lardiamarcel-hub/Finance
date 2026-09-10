import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_repository.dart';
import '../../utils/app_theme.dart';
import '../../widgets/money_text.dart';

/// Résumé des ventes : 3 chiffres, gros et clairs. Pas de graphique
/// compliqué — juste une barre simple pour comparer visuellement.
class SalesSummaryScreen extends StatelessWidget {
  const SalesSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final week = repo.totalThisWeek;
    final month = repo.totalThisMonth;
    final allTime = repo.totalAllTime;
    final maxValue = [week, month, allTime].reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes ventes')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SummaryCard(
            label: 'Cette semaine',
            amount: week,
            maxValue: maxValue,
            color: AppColors.orange,
          ),
          const SizedBox(height: 16),
          _SummaryCard(
            label: 'Ce mois',
            amount: month,
            maxValue: maxValue,
            color: AppColors.orangeDark,
          ),
          const SizedBox(height: 16),
          _SummaryCard(
            label: 'Total encaissé',
            amount: allTime,
            maxValue: maxValue,
            color: AppColors.green,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final double maxValue;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxValue <= 0 ? 0.0 : (amount / maxValue).clamp(0.05, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          MoneyText(amount: amount, fontSize: 30, color: color),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Container(height: 12, color: color.withOpacity(0.15)),
                  Container(height: 12, width: constraints.maxWidth * ratio, color: color),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
