import 'package:front/presentation/screens/exercice_uno/models/card_model.dart';

class CardCollection {
  final StackCard card;
  final int quantity;
  final String displayName;

  CardCollection({
    required this.card,
    required this.quantity,
    String? displayName,
  }) : displayName = displayName ?? card.label ?? card.id;

  bool get hasStock => quantity > 0;

  CardCollection copyWith({int? quantity}) {
    return CardCollection(
      card: card,
      quantity: quantity ?? this.quantity,
      displayName: displayName,
    );
  }
}
