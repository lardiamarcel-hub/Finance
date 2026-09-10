import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';

/// Affiche un montant en très gros, toujours bien visible (principe de
/// conception n°6 : le total se voit tout de suite, sans effort).
class MoneyText extends StatelessWidget {
  final num amount;
  final double fontSize;
  final Color color;

  const MoneyText({
    super.key,
    required this.amount,
    this.fontSize = 32,
    this.color = AppColors.textDark,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      formatFcfa(amount),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: color,
      ),
    );
  }
}
