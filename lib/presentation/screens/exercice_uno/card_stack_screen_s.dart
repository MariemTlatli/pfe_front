import 'package:flutter/material.dart';
import 'package:front/presentation/provider/card_provider.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/card_stack_view_page.dart';
import 'package:front/presentation/screens/exercice_uno/models/card_collection.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/card_dialog.dart';
import 'package:front/presentation/screens/exercice_uno/widgets/fake_exercice_widget.dart';

import 'package:provider/provider.dart';

class CardStackScreenEdited extends StatefulWidget {
  final String userId;
  final double difficulty;

  const CardStackScreenEdited({
    super.key,
    required this.userId,
    required this.difficulty,
  });

  @override
  State<CardStackScreenEdited> createState() => _CardStackScreenState();
}

class _CardStackScreenState extends State<CardStackScreenEdited> {
  CardCollection? selectedCard;

  @override
  void initState() {
    super.initState();
    // Chargement automatique à l'ouverture
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardProvider>().loadAndMapCards(
        userId: widget.userId,
        difficulty: widget.difficulty,
        nbCartes: 7,
      );
    });
  }

  void _openCardDialog() async {
    final provider = context.read<CardProvider>();

    // Charge les cartes spéciales depuis l'API
    await provider.loadSpecialCards(widget.userId);

    final specialStatus = provider.specialCardsStatus;
    if (specialStatus == null) {
      _msg(context, '❌ Erreur: Impossible de charger les cartes spéciales');
      return;
    }

    if (!specialStatus.hasSpecialCards) {
      _msg(context, '✨ Aucune carte spéciale disponible');
      return;
    }

    // Convertit en collections affichables
    final specialCollections = specialStatus.toCardCollections();

    // Ouvre la boîte de dialogue avec les cartes spéciales
    final selected = await CardDialog.show(context, specialCollections);
    if (selected != null) {
      setState(() => selectedCard = selected);
      print("ici je dois implémenter carte effet");
      _msg(context, '✅ Carte spéciale sélectionnée: ${selected.displayName}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('❌ ${provider.error}', textAlign: TextAlign.center),
              ),
            );
          }
          if (provider.cards.isEmpty) {
            return const Center(child: Text('Aucune carte distribuée.'));
          }
          // ✅ COLLECTE TOUTES LES CARTES EN UNE SEULE LISTE
          final allAssetPaths = provider.cards
              .expand((collection) => collection.card.assetPaths)
              .toList();

          print('🎴 Nombre total de cartes: ${allAssetPaths.length}');
          print(' Asset paths: $allAssetPaths');

          return Column(
            children: [
              // Container(
              //   height: 250,
              //   color: Color.fromARGB(255, 255, 255, 255),
              //   child: Column(
              //     children: specialSelectedCard(context, allAssetPaths),
              //   ),
              // ),
              Flexible(child: const FakeExerciceWidget()),
            ],
          );
        },
      ),
    );
  }

  List<Widget> specialSelectedCard(
    BuildContext context,
    List<String> allAssetPaths,
  ) {
    return [
      const SizedBox(height: 10),
      Expanded(
        flex: 1,
        child: ElevatedButton.icon(
          onPressed: _openCardDialog,
          icon: const Icon(Icons.card_giftcard),
          label: const Text(
            'Ouvrir sélecteur de cartes',
            style: TextStyle(
              fontWeight: FontWeight.bold, // Texte en gras
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            foregroundColor: Colors.amber,
            side: const BorderSide(color: Colors.amber, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
          ),
        ),
      ),
      const SizedBox(height: 20),
      Expanded(flex: 2, child: buildArcHand(context, allAssetPaths)),
    
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
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
      Expanded(flex: 1, child: Text("")),
    ];
  }

  void _msg(BuildContext ctx, String txt) =>
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(txt)));
}
