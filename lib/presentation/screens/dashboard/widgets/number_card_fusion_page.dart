import 'package:flutter/material.dart';
import 'package:front/data/data_sources/adaptive_exercise_remote_data_source.dart';
import 'package:provider/provider.dart';
import 'package:front/core/api/http_consumer.dart';

class NumberCardFusionPage extends StatefulWidget {
  final String userId;
  
  const NumberCardFusionPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<NumberCardFusionPage> createState() => _NumberCardFusionPageState();
}

class _NumberCardFusionPageState extends State<NumberCardFusionPage> {
  Map<String, dynamic> inventory = {};
  bool isLoading = true;
  late final AdaptiveExerciseRemoteDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    final apiConsumer = context.read<HttpConsumer>();
    _dataSource = AdaptiveExerciseRemoteDataSource(apiConsumer: apiConsumer);
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => isLoading = true);
    try {
      final res = await _dataSource.getNumberCardsInventory(widget.userId);
      if (mounted) {
        setState(() { 
          inventory = res['inventory'] ?? {}; 
          isLoading = false; 
        });
      }
    } catch (e) {
      print("Erreur chargement inventaire: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _mergeCard(String color, int number) async {
    setState(() => isLoading = true);
    
    try {
      final res = await _dataSource.mergeNumberCards(widget.userId, color, number);
      
      if (!mounted) return;
      
      if(res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("🎉 " + (res['message'] ?? 'Fusion réussie')))
        );
        
        final List? newBadges = res['new_badges'];
        if (newBadges != null && newBadges.isNotEmpty) {
           _showBadgeDialog(newBadges);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Erreur de fusion'), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Une erreur réseau s'est produite"), backgroundColor: Colors.red)
         );
       }
    }
    
    await _loadCards(); // Rafraichir l'inventaire
  }

  void _showBadgeDialog(List newBadges) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("🏆 NOUVEAU BADGE DÉBLOQUÉ !"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: newBadges.map((badge) => ListTile(
            leading: Text(badge['icon'] ?? '⭐', style: const TextStyle(fontSize: 30)),
            title: Text(badge['name'] ?? ''),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), 
            child: const Text("Génial !")
          )
        ],
      )
    );
  }

  Color _getColor(String c) {
    switch(c) {
      case 'r': return Colors.red;
      case 'b': return Colors.blue;
      case 'v': return Colors.green;
      case 'j': return Colors.yellow[700]!;
      default: return Colors.grey;
    }
  }

  String _getColorName(String c) {
    switch(c) {
      case 'r': return 'Rouge';
      case 'b': return 'Bleu';
      case 'v': return 'Vert';
      case 'j': return 'Jaune';
      default: return '?';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laboratoire de Fusion"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.indigo],
            ),
          ),
        ),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : inventory.isEmpty
          ? const Center(child: Text("Ton laboratoire est vide. Fais des exercices pour gagner des cartes '1' !"))
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: inventory.entries.map((entry) {
                final parts = entry.key.split('_'); // "r_1" => ["r", "1"]
                final colorCode = parts[0];
                final number = int.parse(parts[1]);
                final count = entry.value;

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: _getColor(colorCode),
                      child: Text(
                        number.toString(), 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)
                      ),
                    ),
                    title: Text("Carte '$number' ${_getColorName(colorCode)} (x$count)", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(count >= 2 
                        ? "Prêt pour la fusion vers le ${number + 1} ! 🔨" 
                        : "Trouvez encore ${2 - count} cartes pour fusionner."),
                    ),
                    trailing: count >= 2 
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white
                          ),
                          onPressed: number < 9 ? () => _mergeCard(colorCode, number) : null, 
                          child: const Text("Fusionner")
                        )
                      : const Icon(Icons.lock, color: Colors.grey, size: 30),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
