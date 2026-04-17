import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:front/data/data_sources/card_relote_data_source.dart';
import 'package:front/data/models/special_cards_model.dart';
import 'package:front/presentation/screens/exercice_uno/models/card_mapper.dart';
import 'package:front/presentation/screens/exercice_uno/models/card_collection.dart';
import 'package:front/presentation/screens/exercice_uno/models/card_model.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/card_dialog.dart';

// Importe tes modèles existants

class CardProvider extends ChangeNotifier {
  final CardRemote_dataSource dataSource;

  CardProvider({required CardRemote_dataSource this.dataSource});

  List<CardCollection> _cards = [];
  List<CardCollection> get cards => _cards;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadAndMapCards({
    required String userId,
    required double difficulty,
    required int nbCartes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final apiCards = await dataSource.fetchInitialCards(
        userId: userId,
        difficulty: difficulty,
        nbCartes: nbCartes,
      );

      _cards = apiCards.asMap().entries.map((entry) {
        final apiCard = entry.value;
        final assetPath = getCardAssetPath(
          couleur: apiCard.couleur,
          valeur: (apiCard.valeur).toInt(),
        );

        final stackCard = StackCard(
          id: 'card_${entry.key}',
          assetPaths: [assetPath],
          face: CardFace.faceUp,
          // Note: .toString() sur AssetImage est déconseillé. On garde la string brute ici.
          imageProvider: assetPath,
          label: '${apiCard.couleur.toUpperCase()}${apiCard.valeur}',
        );

        return CardCollection(
          card: stackCard,
          quantity: 1,
          displayName:
              'Carte ${apiCard.couleur.toUpperCase()}${apiCard.valeur}',
        );
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _cards.clear();
    _error = null;
    notifyListeners();
  }

  // ➕ NOUVEAU : État pour les cartes spéciales
  SpecialCardsStatus? _specialCardsStatus;
  SpecialCardsStatus? get specialCardsStatus => _specialCardsStatus;

  bool _isSpecialCardsLoading = false;
  bool get isSpecialCardsLoading => _isSpecialCardsLoading;

  // ➕ NOUVEAU : Méthode de chargement
  Future<void> loadSpecialCards(String userId) async {
    _isSpecialCardsLoading = true;
    notifyListeners();

    try {
      _specialCardsStatus = await dataSource.fetchSpecialCardsStatus(userId);
    } catch (e) {
      _error = 'Cartes spéciales: ${e.toString()}';
      print('❌ loadSpecialCards error: $e');
    } finally {
      _isSpecialCardsLoading = false;
      notifyListeners();
    }
  }

  Future<void> openSpecialCardsDialog(
    BuildContext context,
    String userId,
  ) async {
    // Charge si pas déjà chargé ou si force refresh
    if (_specialCardsStatus == null) {
      print("_specialCardsStatus == null");
      await loadSpecialCards(userId);
    }
    if (userId == "user123") {
      print("user123");
    }

    if (_specialCardsStatus == null) {
      _showError(context, 'Impossible de charger les cartes spéciales');
      return;
    }

    if (!_specialCardsStatus!.hasSpecialCards) {
      print(_specialCardsStatus!.hasSpecialCards);
      _showInfo(context, '✨ Aucune carte spéciale disponible pour le moment');
      return;
    }

    // Convertit en liste affichable
    final specialCollections = _specialCardsStatus!.toCardCollections();
    print("specialCollections");
    // Ouvre le dialog
    final selected = await CardDialog.show(context, specialCollections);
    if (selected != null) {
      print('✅ Carte spéciale sélectionnée: ${selected.displayName}');
      // Tu peux ajouter une logique de sélection ici
    }
  }

  void _showError(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text('❌ $msg'), backgroundColor: Colors.red),
    );
  }

  void _showInfo(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(
      ctx,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.blue));
  }
}
