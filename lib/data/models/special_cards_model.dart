import 'package:front/presentation/screens/exercice_uno/models/card_collection.dart';
import 'package:front/presentation/screens/exercice_uno/models/card_mapper.dart';
import 'package:front/presentation/screens/exercice_uno/models/card_model.dart';

class SpecialCardsStatus {
  final int jokerCards;
  final int plus4Cards;
  final int reverseCards;
  final int skipCards;
  final int plus2Cards;

  SpecialCardsStatus({
    required this.jokerCards,
    required this.plus4Cards,
    required this.reverseCards,
    required this.skipCards,
    required this.plus2Cards,
  });

  factory SpecialCardsStatus.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
    return SpecialCardsStatus(
      jokerCards: data['joker_cards'] ?? 0,
      plus4Cards: data['plus4_cards'] ?? 0,
      reverseCards: data['reverse_cards'] ?? 0,
      skipCards: data['skip_cards'] ?? 0,
      plus2Cards: data['plus2_cards'] ?? 0,
    );
  }


  List<CardCollection> toCardCollections() {
    final collections = <CardCollection>[];
    _addIfAvailable(collections, 'joker', jokerCards, '🃏 Joker');
    _addIfAvailable(collections, 'plus4', plus4Cards, '➕ +4');
    _addIfAvailable(collections, 'reverse', reverseCards, '🔁 Reverse');
    _addIfAvailable(collections, 'skip', skipCards, '⏭️ Skip');
    _addIfAvailable(collections, 'plus2', plus2Cards, '➕ +2');
    return collections;
  }

  String getImagePath(String type) => 'lib/presentation/screens/exercice_uno/card_img/special_$type.png';

  void _addIfAvailable(List<CardCollection> list, String type, int quantity, String label) {
    if (quantity > 0) {
      final assetPath = getSpecialCardAssetPath(type: type);
      final stackCard = StackCard(
        id: 'special_$type',
        assetPaths: [assetPath],
        face: CardFace.faceUp,
        imageProvider: assetPath,
        label: 'special_$type',
      );
      list.add(CardCollection(card: stackCard, quantity: quantity, displayName: '$label (x$quantity)'));
    }
  }

  bool get hasSpecialCards =>
      jokerCards > 0 || plus4Cards > 0 || reverseCards > 0 || skipCards > 0 || plus2Cards > 0;
}

