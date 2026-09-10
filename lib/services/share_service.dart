import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Regroupe les façons d'envoyer un document : WhatsApp, SMS, ou simple
/// téléchargement. Tout reste utilisable hors-ligne (le partage lui-même
/// ne se fait que lorsque l'utilisateur choisit une appli qui a du réseau).
class ShareService {
  /// Écrit le PDF dans le dossier de documents de l'app et retourne le
  /// fichier créé.
  static Future<File> savePdfToDevice(Uint8List bytes, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Ouvre la feuille de partage native avec le PDF déjà sélectionné :
  /// l'utilisateur choisit WhatsApp (ou une autre appli) dans la liste.
  static Future<void> sharePdf(File file, {required String subject}) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: subject,
      text: subject,
    );
  }

  /// Envoie un message texte pré-rempli par SMS (le PDF reste joignable
  /// séparément : les SMS ne transportent pas de fichiers).
  static Future<void> sendSms({required String phone, required String message}) async {
    final uri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': message},
    );
    await launchUrl(uri);
  }

  static Future<void> callPhone(String phone) async {
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  static Future<void> openWhatsAppChat({required String phone, String? message}) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse(
      'https://wa.me/$cleanPhone${message != null ? '?text=${Uri.encodeComponent(message)}' : ''}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
