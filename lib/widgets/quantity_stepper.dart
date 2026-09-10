import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Boutons +/- pour choisir une quantité, sans jamais avoir à taper un
/// chiffre au clavier (principe de conception n°9).
class QuantityStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          icon: Icons.remove_rounded,
          onTap: value > min ? () => onChanged(value - 1) : null,
        ),
        Container(
          width: 48,
          alignment: Alignment.center,
          child: Text(
            '$value',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
        _StepperButton(
          icon: Icons.add_rounded,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: enabled ? AppColors.orange : Colors.grey.shade300,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
