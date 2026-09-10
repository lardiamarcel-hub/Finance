const _months = [
  'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
  'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
];

/// Formate une date en français simple, ex: "12 mars 2026".
/// Écrit à la main (sans dépendre des données de locale d'intl) pour rester
/// léger et fiable hors-ligne.
String formatDateFr(DateTime date) {
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}

String formatDateShortFr(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$d/$m/${date.year}';
}
