# Devis Sap Sap

Application mobile de devis et factures, pensée pour les petits commerçants
et artisans du Burkina Faso : peu de texte, de gros boutons, des icônes
partout, et un fonctionnement 100% hors-ligne.

## Démarrer le projet en local

Ce dépôt contient uniquement le code Dart de l'application (`lib/`) et sa
configuration (`pubspec.yaml`). Les dossiers natifs Android/iOS/web ne sont
**pas** inclus (ils sont générés par l'outil Flutter, pas écrits à la main).

Sur ta machine, avec le SDK Flutter installé :

```bash
flutter create --project-name devis_sap_sap --org com.devissapsap .
flutter pub get
flutter run
```

`flutter create .` détecte que `lib/` et `pubspec.yaml` existent déjà : il
ajoute seulement les dossiers `android/`, `ios/`, etc. sans toucher au code.

## Arborescence

```
lib/
  main.dart                     Point d'entrée, thème, attente du chargement local
  models/                       Client, Product, DevisItem, Devis, Company
  data/
    app_repository.dart         Source unique de données (offline-first, Firebase plus tard)
  services/
    pdf_service.dart            Génération du PDF (devis/facture + reçu)
    share_service.dart          Envoi WhatsApp / SMS / appel / téléchargement
    ai_devis_service.dart       Assistant IA (Google Gemini) : texte -> client + articles
  config/
    ai_config.dart               Clé IA injectée à la compilation (jamais en clair dans le code)
  utils/
    app_theme.dart               Palette de couleurs et styles
    currency_formatter.dart      Format FCFA ("15 000 FCFA")
    date_formatter.dart          Dates en français
    collection_extensions.dart
  widgets/                      Composants réutilisés partout (gros boutons, badges de statut,
                                 sélecteur de quantité +/-, montant en gros, avatar initiale,
                                 bottom sheet "nouveau client")
  screens/
    onboarding/company_setup_screen.dart Fiche entreprise (1ère fois, puis modifiable) —
                                          premier écran tant qu'aucun compte n'est branché
    home/home_screen.dart               Accueil : devis récents + actions principales
    devis/
      devis_wizard_screen.dart          Parcours en 4 étapes (voir plus bas)
      ai_devis_sheet.dart                "Décrire avec l'IA" (bouton ✨ à l'étape Client)
      steps/client_step.dart
      steps/items_step.dart
      steps/summary_step.dart
      steps/send_step.dart
      devis_sent_screen.dart            Confirmation "Devis envoyé !"
      devis_detail_screen.dart          Détail + accepter/refuser/payer/modifier/renvoyer
    clients/
      clients_list_screen.dart          Carnet de clients
      client_detail_screen.dart         Fiche client (historique, appel, WhatsApp)
    catalog/catalog_screen.dart         Produits/services habituels
    sales/sales_summary_screen.dart     3 chiffres : semaine / mois / total
    settings/
      settings_screen.dart              Fiche entreprise, langue, aide
      help_screen.dart                  Aide illustrée
assets/images/                          Logos/photos (vide pour l'instant)
```

## Plan de développement (suivi dans ce dépôt)

1. **Modèles et données** — `Client`, `Product`, `Devis`, `Company` + un
   `AppRepository` qui centralise toutes les données, les sauvegarde en
   local (`shared_preferences`, donc disponible hors-ligne) et démarre avec
   des données de démonstration pour que l'app ne soit jamais vide.
2. **Thème et composants** — palette orange/vert chaleureuse et lisible en
   plein soleil, gros boutons, montants en gros caractères, formatage FCFA.
3. **Parcours de création de devis** (la fonctionnalité la plus importante) —
   4 étapes (Client → Articles → Récapitulatif → Envoi), calcul automatique
   du total, génération de PDF sur l'appareil, envoi par WhatsApp/SMS ou
   téléchargement.
4. **Détail d'un devis** — accepter (devient une facture sans ressaisie),
   refuser, marquer payé (génère un reçu), modifier les quantités, renvoyer.
5. **Carnet de clients et catalogue produits** — pour ne jamais retaper une
   information déjà connue.
6. **Résumé des ventes, paramètres et aide** — 3 chiffres clairs, fiche
   entreprise modifiable, écran d'aide illustré.
7. **Écran de configuration** et branchement dans `main.dart` : au premier
   lancement, l'app va directement à la fiche entreprise, puis à l'accueil —
   pas d'écran de connexion pour l'instant, pour pouvoir tester librement.
8. **Firebase (Auth téléphone + Firestore + synchro hors-ligne)** — pas
   encore fait. C'est la prochaine étape : brancher `AppRepository` sur
   Firestore (avec la persistance offline de Firestore activée) derrière la
   même interface, et ajouter un écran de connexion (téléphone + SMS) sans
   retoucher le reste des écrans.

### Explication simple de ce qui a été construit

- **Les données** : tout ce que tu crées (client, produit, devis) est
  sauvegardé directement sur le téléphone, donc ça marche même sans
  Internet.
- **La création d'un devis** : tu avances étape par étape (client, puis
  articles, puis tu vérifies, puis tu envoies) — jamais un long formulaire
  à remplir d'un coup.
- **L'envoi** : un devis se transforme en PDF propre et peut partir
  directement sur WhatsApp, par SMS, ou être téléchargé.
- **Le suivi** : chaque devis a une pastille de couleur (jaune = en
  attente, vert = accepté/payé, rouge = refusé), visible sans avoir à lire
  de texte.
- **Ce qui reste à faire** : ajouter un vrai compte (numéro de téléphone +
  code SMS) et synchroniser les données entre plusieurs appareils via
  Firebase — pour l'instant tout reste local à l'appareil, sans connexion à
  faire pour commencer à tester.

## Assistant IA (optionnel)

Depuis l'étape "Client" du parcours de devis, un bouton ✨ ouvre un champ de
texte libre ("Décrire ton besoin") : l'utilisateur écrit sa demande en une
phrase ("Devis pour Awa, 2 sacs de riz et une livraison"), et l'IA
(Google Gemini, offre gratuite) propose un client et une liste d'articles
avec quantités et prix. Le brouillon atterrit directement sur l'étape
Récapitulatif : **rien n'est jamais envoyé automatiquement**, l'utilisateur
vérifie et corrige (y compris les prix, via l'icône crayon sur une ligne)
avant d'envoyer, comme pour un devis fait à la main.

Détails techniques :
- La fonction réutilise en priorité les clients et produits déjà connus
  (correspondance par nom) ; elle ne crée un nouveau client/article que si
  rien ne correspond.
- Nécessite une connexion Internet ; le reste de l'app continue de
  fonctionner 100% hors-ligne comme avant. Si la clé IA n'est pas
  configurée sur un build donné, le bouton ✨ ne s'affiche simplement pas.
- La clé API n'est **jamais** écrite dans le code source : elle est injectée
  au moment de la compilation via `--dart-define=GEMINI_API_KEY=...` (voir
  `.github/workflows/build-apk.yml`), lue depuis un secret du dépôt GitHub
  (`Settings → Secrets and variables → Actions → GEMINI_API_KEY`), et lue
  côté app dans `lib/config/ai_config.dart` via `String.fromEnvironment`.
  Un build local sans ce secret compile normalement, juste sans le bouton ✨.

## Ce qui n'est pas encore branché

- Pas d'écran de connexion : l'app s'ouvre directement sur la fiche
  entreprise (1ère fois) puis l'accueil, pour tester sans friction avant la
  mise en œuvre de Firebase Auth (téléphone + SMS).
- Il n'y a pas encore de synchronisation multi-appareils : les données
  restent sur le téléphone (ce qui correspond déjà au mode hors-ligne
  demandé, juste sans la synchronisation en plus).
