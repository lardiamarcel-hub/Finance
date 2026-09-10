/// Formate un montant en FCFA avec l'espace comme séparateur de milliers,
/// sans décimales (usage courant au Burkina Faso : "15 000 FCFA").
String formatFcfa(num amount) {
  final rounded = amount.round();
  final digits = rounded.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    final positionFromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
      buffer.write(' ');
    }
  }

  final sign = rounded < 0 ? '-' : '';
  return '$sign${buffer.toString()} FCFA';
}
