import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/client.dart';
import '../models/company.dart';
import '../models/devis.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

/// Construit le PDF d'un devis ou d'une facture : propre, sobre, et lisible
/// même imprimé en noir et blanc. Tout se fait sur l'appareil, sans réseau.
class PdfService {
  static Future<Uint8List> generateDevisPdf({
    required Devis devis,
    required Company company,
    required Client client,
  }) async {
    final doc = pw.Document();

    pw.MemoryImage? logo;
    final logoPath = company.logoPath;
    if (logoPath != null && logoPath.isNotEmpty) {
      try {
        final bytes = await File(logoPath).readAsBytes();
        logo = pw.MemoryImage(bytes);
      } catch (_) {
        logo = null;
      }
    }

    final docTitle = devis.isInvoice ? 'FACTURE' : 'DEVIS';
    final docNumber = devis.id.substring(0, 8).toUpperCase();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(company, logo, docTitle, docNumber, devis),
        footer: (context) => _buildFooter(),
        build: (context) => [
          pw.SizedBox(height: 16),
          _buildClientBlock(client),
          pw.SizedBox(height: 20),
          _buildItemsTable(devis),
          pw.SizedBox(height: 16),
          _buildTotalRow(devis),
          if (devis.isInvoice && devis.isPaid) ...[
            pw.SizedBox(height: 24),
            _buildPaidStamp(devis),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildHeader(
    Company company,
    pw.MemoryImage? logo,
    String docTitle,
    String docNumber,
    Devis devis,
  ) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    company.name.isEmpty ? 'Mon commerce' : company.name,
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (company.city.isNotEmpty) pw.Text(company.city),
                  if (company.phone.isNotEmpty) pw.Text('Tél : ${company.phone}'),
                ],
              ),
            ),
            if (logo != null) pw.Image(logo, width: 64, height: 64),
          ],
        ),
        pw.SizedBox(height: 18),
        pw.Container(height: 2, color: PdfColors.orange700),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              docTitle,
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('N° $docNumber'),
                pw.Text(formatDateFr(devis.createdAt)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildClientBlock(Client client) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Client', style: const pw.TextStyle(color: PdfColors.grey700)),
          pw.SizedBox(height: 4),
          pw.Text(
            client.name,
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          if (client.phone.isNotEmpty) pw.Text(client.phone),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(Devis devis) {
    return pw.TableHelper.fromTextArray(
      headerDecoration: const pw.BoxDecoration(color: PdfColors.orange700),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
      ),
      cellAlignment: pw.Alignment.centerLeft,
      cellAlignments: {
        1: pw.Alignment.center,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      headers: ['Article', 'Qté', 'Prix unitaire', 'Total'],
      data: devis.items
          .map((item) => [
                item.productName,
                '${item.quantity}',
                formatFcfa(item.unitPrice),
                formatFcfa(item.total),
              ])
          .toList(),
    );
  }

  static pw.Widget _buildTotalRow(Devis devis) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: pw.BoxDecoration(
          color: PdfColors.orange50,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Text(
          'Total : ${formatFcfa(devis.total)}',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
      ),
    );
  }

  static pw.Widget _buildPaidStamp(Devis devis) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.green700, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        'PAYÉ le ${formatDateFr(devis.paidAt!)}',
        style: pw.TextStyle(
          color: PdfColors.green700,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.SizedBox(height: 8),
        pw.Text(
          'Merci de votre confiance',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }

  /// PDF court pour un reçu de paiement (plus simple qu'une facture).
  static Future<Uint8List> generateReceiptPdf({
    required Devis devis,
    required Company company,
    required Client client,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              company.name.isEmpty ? 'Mon commerce' : company.name,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            if (company.phone.isNotEmpty) pw.Text('Tél : ${company.phone}'),
            pw.SizedBox(height: 16),
            pw.Container(height: 2, color: PdfColors.green700),
            pw.SizedBox(height: 16),
            pw.Text(
              'REÇU DE PAIEMENT',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Reçu de : ${client.name}'),
            pw.Text('Date : ${formatDateFr(devis.paidAt ?? devis.createdAt)}'),
            pw.SizedBox(height: 16),
            pw.Text(
              'Montant payé : ${formatFcfa(devis.total)}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              'Merci de votre confiance !',
              style: const pw.TextStyle(color: PdfColors.grey600),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }
}
