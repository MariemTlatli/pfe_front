import 'package:flutter/material.dart';
import 'package:front/presentation/provider/discovery_provider.dart';
import 'package:front/presentation/widgets/uno_card.dart';
import 'package:provider/provider.dart';

class SubjectHeader extends StatelessWidget {
  const SubjectHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<DiscoveryProvider>().state.selectedDomain;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
  decoration: BoxDecoration(
    color: const Color(0xFFFF6B4A), // Orange/corail
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Colors.white,
      width: 2,
    ),
  ),
  child: Center(
    child: IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
    ),
  ),
),
          const SizedBox(width: 40),

           UnoCard(
            height: 45,
            width: 220,
            label: domain?.name ?? "Matières",
            onTap: () {}, // Optional action
            content: Center(
              child: Text(
                domain?.name ?? "Matières",
                style: TextStyle(
                  color: Color(0xFF424242),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),   
            ],
          ),
        ],
      ),
    );
  }
}
