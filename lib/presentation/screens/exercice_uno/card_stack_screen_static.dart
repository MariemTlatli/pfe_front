import 'package:flutter/material.dart';
import 'package:front/presentation/provider/card_provider.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/card_stack_view_page.dart';
import 'package:front/presentation/screens/exercice_uno/models/card_collection.dart';
import 'package:front/presentation/screens/exercice_uno/models/card_model.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/card_dialog.dart';
import 'package:provider/provider.dart';

class CardStackScreenStatic extends StatefulWidget {
  const CardStackScreenStatic({super.key});

  @override
  State<CardStackScreenStatic> createState() => _CardStackScreenState();
}

class _CardStackScreenState extends State<CardStackScreenStatic> {
  CardCollection? selectedCard;

  final assetPaths = [
    'lib/presentation/screens/exercice_uno/card_img/r1.png',
    'lib/presentation/screens/exercice_uno/card_img/r1.png',
    'lib/presentation/screens/exercice_uno/card_img/r1.png',
    'lib/presentation/screens/exercice_uno/card_img/r1.png',
    'lib/presentation/screens/exercice_uno/card_img/r1.png',
  ];

  late List<CardCollection> cardCollections;

  @override
  void initState() {
    super.initState();
    _initializeCards();
  }

  void _initializeCards() {
    cardCollections = assetPaths.asMap().entries.map((entry) {
      int index = entry.key;
      String assetPath = entry.value;

      final stackCard = StackCard(
        id: 'card_$index',
        assetPaths: [assetPath],
        face: CardFace.faceUp,
        imageProvider: AssetImage(assetPath).toString(),
        label: 'Carte ${index + 1}',
      );

      return CardCollection(
        card: stackCard,
        quantity: 1,
        displayName: 'Carte ${index + 1}',
      );
    }).toList();
  }

  void _openCardDialog() async {
    final provider = context.read<CardProvider>();

    final specialStatus = await provider.specialCardsStatus;

    if (specialStatus == null) return;

    final selected = await CardDialog.specialShow(context, specialStatus);

    if (selected != null) {
      setState(() {
        selectedCard = selected;
      });
      _msg(context, '✅ Carte sélectionnée: ${selected.displayName}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Card Stack',
          style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.w900),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  buildArcHand(
                    context,
                    cardCollections
                        .expand((collection) => collection.card.assetPaths)
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _openCardDialog,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Ouvrir sélecteur de cartes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              if (selectedCard != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Carte sélectionnée :',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedCard!.displayName,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Quantité: ${selectedCard!.quantity}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _msg(BuildContext ctx, String txt) =>
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(txt)));
}
