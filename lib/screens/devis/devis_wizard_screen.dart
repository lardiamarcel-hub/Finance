import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_repository.dart';
import '../../models/client.dart';
import '../../models/devis.dart';
import '../../models/devis_item.dart';
import '../../services/ai_devis_service.dart';
import '../../services/pdf_service.dart';
import '../../services/share_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/currency_formatter.dart';
import 'ai_devis_sheet.dart';
import 'devis_sent_screen.dart';
import 'steps/client_step.dart';
import 'steps/items_step.dart';
import 'steps/send_step.dart';
import 'steps/summary_step.dart';

/// Parcours en 4 étapes pour créer un devis : Client -> Articles ->
/// Récapitulatif -> Envoi. Un seul écran gère l'état du brouillon pour que
/// rien ne se perde en avançant/reculant entre les étapes.
class DevisWizardScreen extends StatefulWidget {
  const DevisWizardScreen({super.key});

  @override
  State<DevisWizardScreen> createState() => _DevisWizardScreenState();
}

class _DevisWizardScreenState extends State<DevisWizardScreen> {
  final _pageController = PageController();
  int _step = 0;

  Client? _selectedClient;
  final List<DevisItem> _items = [];
  bool _isSending = false;
  Devis? _createdDevis;

  static const _titles = ['Client', 'Articles', 'Récapitulatif', 'Envoi'];

  bool get _canGoNext {
    switch (_step) {
      case 0:
        return _selectedClient != null;
      case 1:
        return _items.isNotEmpty;
      default:
        return true;
    }
  }

  void _goToStep(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _addOrUpdateItem(DevisItem item) {
    setState(() {
      final index = _items.indexWhere((i) => i.productId == item.productId);
      if (index == -1) {
        _items.add(item);
      } else {
        _items[index] = item;
      }
    });
  }

  void _removeItem(String productId) {
    setState(() => _items.removeWhere((i) => i.productId == productId));
  }

  Future<void> _openAiSheet() async {
    final result = await showAiDevisSheet(context);
    if (result == null || !mounted) return;
    setState(() {
      _selectedClient = result.client;
      _items
        ..clear()
        ..addAll(result.items);
    });
    _goToStep(2);
  }

  Future<Devis> _ensureDevisCreated() async {
    if (_createdDevis != null) return _createdDevis!;
    final repo = context.read<AppRepository>();
    final devis = await repo.addDevis(
      clientId: _selectedClient!.id,
      clientName: _selectedClient!.name,
      items: _items,
    );
    _createdDevis = devis;
    return devis;
  }

  Future<void> _runSendAction(Future<void> Function(Devis devis) action) async {
    if (_isSending) return;
    setState(() => _isSending = true);
    try {
      final devis = await _ensureDevisCreated();
      await action(devis);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DevisSentScreen(devisId: devis.id)),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oups, une erreur est survenue. Réessaie.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendWhatsApp() => _runSendAction((devis) async {
        final repo = context.read<AppRepository>();
        final bytes = await PdfService.generateDevisPdf(
          devis: devis,
          company: repo.company,
          client: _selectedClient!,
        );
        final file = await ShareService.savePdfToDevice(
          bytes,
          'devis_${devis.id.substring(0, 8)}.pdf',
        );
        await ShareService.sharePdf(
          file,
          subject: '${devis.isInvoice ? 'Facture' : 'Devis'} pour ${_selectedClient!.name}',
        );
      });

  Future<void> _sendSms() => _runSendAction((devis) async {
        final repo = context.read<AppRepository>();
        await ShareService.sendSms(
          phone: _selectedClient!.phone,
          message:
              'Bonjour ${_selectedClient!.name}, voici votre devis de ${repo.company.name.isEmpty ? 'notre part' : repo.company.name} : total ${formatFcfa(devis.total)}. Merci !',
        );
      });

  Future<void> _downloadPdf() => _runSendAction((devis) async {
        final repo = context.read<AppRepository>();
        final bytes = await PdfService.generateDevisPdf(
          devis: devis,
          company: repo.company,
          client: _selectedClient!,
        );
        await ShareService.sharePdf(
          await ShareService.savePdfToDevice(bytes, 'devis_${devis.id.substring(0, 8)}.pdf'),
          subject: '${devis.isInvoice ? 'Facture' : 'Devis'} pour ${_selectedClient!.name}',
        );
      });

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_step]),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_step == 0 && AiDevisService.isAvailable)
            IconButton(
              icon: const Icon(Icons.auto_awesome_rounded),
              tooltip: "Décrire avec l'IA",
              onPressed: _openAiSheet,
            ),
        ],
      ),
      body: Column(
        children: [
          _StepDots(current: _step, total: _titles.length),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ClientStep(
                  selectedClient: _selectedClient,
                  onSelect: (c) => setState(() => _selectedClient = c),
                ),
                ItemsStep(
                  items: _items,
                  onAddOrUpdate: _addOrUpdateItem,
                  onRemove: _removeItem,
                ),
                SummaryStep(
                  clientName: _selectedClient?.name ?? '',
                  items: _items,
                  onEditQuantity: (item, qty) {
                    if (qty <= 0) {
                      _removeItem(item.productId);
                    } else {
                      _addOrUpdateItem(item.copyWith(quantity: qty));
                    }
                  },
                ),
                SendStep(
                  isSending: _isSending,
                  onSendWhatsApp: _sendWhatsApp,
                  onSendSms: _sendSms,
                  onDownloadPdf: _downloadPdf,
                ),
              ],
            ),
          ),
          if (_step < 3) _buildNavBar(),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return SafeArea(
      minimum: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _goToStep(_step - 1),
                child: const Text('Précédent'),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canGoNext ? () => _goToStep(_step + 1) : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Suivant'),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  final int current;
  final int total;

  const _StepDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) {
          final active = i <= current;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == current ? 28 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: active ? AppColors.orange : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          );
        }),
      ),
    );
  }
}
