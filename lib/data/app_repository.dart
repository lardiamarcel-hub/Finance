import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/client.dart';
import '../models/company.dart';
import '../models/devis.dart';
import '../models/devis_item.dart';
import '../models/product.dart';

/// Source unique de données pour toute l'application.
///
/// Tout passe par ici : les écrans ne lisent/écrivent jamais de fichiers ou
/// de préférences directement. Aujourd'hui les données sont sauvegardées en
/// local (mode hors-ligne à 100%). Plus tard, la synchronisation Firebase
/// viendra se brancher derrière cette même interface, sans changer les
/// écrans.
class AppRepository extends ChangeNotifier {
  static const _keyCompany = 'devis_sap_sap.company';
  static const _keyClients = 'devis_sap_sap.clients';
  static const _keyProducts = 'devis_sap_sap.products';
  static const _keyDevis = 'devis_sap_sap.devis';

  final _uuid = const Uuid();

  Company company = const Company();
  List<Client> clients = [];
  List<Product> products = [];
  List<Devis> devisList = [];

  bool isReady = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final hasData = prefs.containsKey(_keyCompany);

    if (!hasData) {
      _seedDemoData();
      await _saveAll(prefs);
    } else {
      _loadFrom(prefs);
    }

    isReady = true;
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Chargement / sauvegarde locale
  // ---------------------------------------------------------------------

  void _loadFrom(SharedPreferences prefs) {
    final companyJson = prefs.getString(_keyCompany);
    if (companyJson != null) {
      company = Company.fromMap(jsonDecode(companyJson) as Map<String, dynamic>);
    }

    clients = _decodeList(prefs.getString(_keyClients), Client.fromMap);
    products = _decodeList(prefs.getString(_keyProducts), Product.fromMap);
    devisList = _decodeList(prefs.getString(_keyDevis), Devis.fromMap);
  }

  List<T> _decodeList<T>(
    String? raw,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => fromMap(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<void> _saveAll(SharedPreferences prefs) async {
    await prefs.setString(_keyCompany, jsonEncode(company.toMap()));
    await prefs.setString(
      _keyClients,
      jsonEncode(clients.map((c) => c.toMap()).toList()),
    );
    await prefs.setString(
      _keyProducts,
      jsonEncode(products.map((p) => p.toMap()).toList()),
    );
    await prefs.setString(
      _keyDevis,
      jsonEncode(devisList.map((d) => d.toMap()).toList()),
    );
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await _saveAll(prefs);
  }

  String newId() => _uuid.v4();

  // ---------------------------------------------------------------------
  // Entreprise
  // ---------------------------------------------------------------------

  Future<void> setCompany(Company value) async {
    company = value;
    notifyListeners();
    await _persist();
  }

  // ---------------------------------------------------------------------
  // Clients
  // ---------------------------------------------------------------------

  List<Client> get clientsSortedByName =>
      [...clients]..sort((a, b) => a.name.compareTo(b.name));

  Future<Client> addClient({required String name, required String phone}) async {
    final client = Client(
      id: newId(),
      name: name.trim(),
      phone: phone.trim(),
      createdAt: DateTime.now(),
    );
    clients.add(client);
    notifyListeners();
    await _persist();
    return client;
  }

  Future<void> updateClient(Client updated) async {
    final index = clients.indexWhere((c) => c.id == updated.id);
    if (index == -1) return;
    clients[index] = updated;
    notifyListeners();
    await _persist();
  }

  List<Devis> devisForClient(String clientId) => devisList
      .where((d) => d.clientId == clientId)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  double totalPurchasesForClient(String clientId) {
    return devisList
        .where((d) => d.clientId == clientId && d.isInvoice && d.isPaid)
        .fold(0.0, (sum, d) => sum + d.total);
  }

  // ---------------------------------------------------------------------
  // Produits / services
  // ---------------------------------------------------------------------

  List<Product> get productsSortedByName =>
      [...products]..sort((a, b) => a.name.compareTo(b.name));

  Future<Product> addProduct({
    required String name,
    required double price,
    String? photoPath,
  }) async {
    final product = Product(
      id: newId(),
      name: name.trim(),
      price: price,
      photoPath: photoPath,
    );
    products.add(product);
    notifyListeners();
    await _persist();
    return product;
  }

  Future<void> updateProduct(Product updated) async {
    final index = products.indexWhere((p) => p.id == updated.id);
    if (index == -1) return;
    products[index] = updated;
    notifyListeners();
    await _persist();
  }

  // ---------------------------------------------------------------------
  // Devis / factures
  // ---------------------------------------------------------------------

  List<Devis> get devisSortedByDateDesc =>
      [...devisList]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Future<Devis> addDevis({
    required String clientId,
    required String clientName,
    required List<DevisItem> items,
  }) async {
    final devis = Devis(
      id: newId(),
      clientId: clientId,
      clientName: clientName,
      items: items,
      createdAt: DateTime.now(),
    );
    devisList.add(devis);
    notifyListeners();
    await _persist();
    return devis;
  }

  Devis? devisById(String id) {
    for (final d in devisList) {
      if (d.id == id) return d;
    }
    return null;
  }

  Future<void> _replaceDevis(Devis updated) async {
    final index = devisList.indexWhere((d) => d.id == updated.id);
    if (index == -1) return;
    devisList[index] = updated;
    notifyListeners();
    await _persist();
  }

  Future<void> updateDevisItems(String devisId, List<DevisItem> items) async {
    final devis = devisById(devisId);
    if (devis == null) return;
    await _replaceDevis(devis.copyWith(items: items));
  }

  /// "Ce devis est accepté" : passe le statut en accepté ET le transforme
  /// en facture, sans ressaisir aucune information.
  Future<void> acceptDevisAsInvoice(String devisId) async {
    final devis = devisById(devisId);
    if (devis == null) return;
    await _replaceDevis(
      devis.copyWith(status: DevisStatus.accepte, isInvoice: true),
    );
  }

  Future<void> refuseDevis(String devisId) async {
    final devis = devisById(devisId);
    if (devis == null) return;
    await _replaceDevis(devis.copyWith(status: DevisStatus.refuse));
  }

  Future<void> markDevisAsPaid(String devisId) async {
    final devis = devisById(devisId);
    if (devis == null) return;
    await _replaceDevis(
      devis.copyWith(
        status: DevisStatus.accepte,
        isInvoice: true,
        paidAt: DateTime.now(),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Résumé des ventes
  // ---------------------------------------------------------------------

  List<Devis> get _paidInvoices =>
      devisList.where((d) => d.isInvoice && d.isPaid).toList();

  double get totalThisWeek {
    final now = DateTime.now();
    final startOfWeek =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    return _paidInvoices
        .where((d) => d.paidAt!.isAfter(startOfWeek))
        .fold(0.0, (sum, d) => sum + d.total);
  }

  double get totalThisMonth {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return _paidInvoices
        .where((d) => d.paidAt!.isAfter(startOfMonth))
        .fold(0.0, (sum, d) => sum + d.total);
  }

  double get totalAllTime =>
      _paidInvoices.fold(0.0, (sum, d) => sum + d.total);

  // ---------------------------------------------------------------------
  // Données de démonstration (premier lancement uniquement)
  // ---------------------------------------------------------------------

  void _seedDemoData() {
    company = const Company(
      name: 'Boutique Awa',
      phone: '70 00 00 00',
      city: 'Ouagadougou, Dassasgho',
    );

    final client1 = Client(
      id: newId(),
      name: 'Awa Compaoré',
      phone: '70 11 22 33',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    );
    final client2 = Client(
      id: newId(),
      name: 'Issouf Ouédraogo',
      phone: '76 44 55 66',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    );
    clients = [client1, client2];

    final product1 = Product(id: newId(), name: 'Sac de riz 25kg', price: 15000);
    final product2 = Product(id: newId(), name: 'Bidon d\'huile 5L', price: 6000);
    final product3 = Product(id: newId(), name: 'Livraison', price: 1000);
    products = [product1, product2, product3];

    final devis1 = Devis(
      id: newId(),
      clientId: client1.id,
      clientName: client1.name,
      items: [
        DevisItem(
          productId: product1.id,
          productName: product1.name,
          unitPrice: product1.price,
          quantity: 2,
        ),
        DevisItem(
          productId: product3.id,
          productName: product3.name,
          unitPrice: product3.price,
          quantity: 1,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      status: DevisStatus.accepte,
      isInvoice: true,
      paidAt: DateTime.now().subtract(const Duration(days: 1)),
    );
    final devis2 = Devis(
      id: newId(),
      clientId: client2.id,
      clientName: client2.name,
      items: [
        DevisItem(
          productId: product2.id,
          productName: product2.name,
          unitPrice: product2.price,
          quantity: 3,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      status: DevisStatus.enAttente,
    );
    devisList = [devis1, devis2];
  }
}
