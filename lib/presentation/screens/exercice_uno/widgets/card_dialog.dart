import 'package:flutter/material.dart';
import 'package:front/data/models/special_cards_model.dart';
import 'package:front/presentation/widgets/uno_card.dart';
import '../models/card_collection.dart';
import 'card_grid.dart';

class CardDialog extends StatefulWidget {
  final List<CardCollection> collections;
  final bool isSpecialMode;

  const CardDialog({
    Key? key,
    required this.collections,
    this.isSpecialMode = false,
  }) : super(key: key);

  static Future<CardCollection?> show(
    BuildContext context,
    List<CardCollection> collections,
  ) {
    return showDialog<CardCollection>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          CardDialog(collections: collections, isSpecialMode: false),
    );
  }

  static Future<CardCollection?> specialShow(
    BuildContext context,
    SpecialCardsStatus special,
  ) async {
    final specialCollections = special.toCardCollections();

    return showDialog<CardCollection>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          CardDialog(collections: specialCollections, isSpecialMode: true),
    );
  }

  @override
  State<CardDialog> createState() => _CardDialogState();
}

class _CardDialogState extends State<CardDialog> {
  String? _selectedCardId;

  CardCollection? get _selectedCollection {
    if (_selectedCardId == null) return null;
    return widget.collections.firstWhere(
      (c) => c.card.id == _selectedCardId,
      orElse: () => widget.collections.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              Flexible(
                child: CardGrid(
                  collections: widget.collections,
                  selectedCardId: _selectedCardId,
                  onCardSelected: (collection) {
                    setState(() {
                      _selectedCardId = collection.card.id;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // Fond sombre comme dans l'image
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20), // Coins arrondis en haut
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(98, 121, 121, 121),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: UnoCard(
              height: 45,
              width: 220,
              label: 'Cartes Spéciales',
              onTap: () {}, // Optional action
              content: const Center(
                child: Text(
                  'Cartes Spéciales',
                  style: TextStyle(
                    color: Color(0xFF424242),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),

            
          ),

          Expanded(
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white70),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Annuler'),
          ),
        ),
        SizedBox(width: 5, height: 10),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _selectedCollection != null
                ? () => Navigator.of(context).pop(_selectedCollection)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Utiliser cette carte'),
          ),
        ),
      ],
    );
  }
}
