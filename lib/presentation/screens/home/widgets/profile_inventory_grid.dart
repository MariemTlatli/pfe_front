import 'package:flutter/material.dart';
import 'package:front/presentation/widgets/uno_card.dart';
import '../../../../data/models/user_model.dart';
import '../../dashboard/widgets/number_card_fusion_page.dart';

class ProfileInventoryGrid extends StatelessWidget {
  final UserModel user;

  const ProfileInventoryGrid({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UnoCard(
          height: 45,
          width: 220,
          label: "CARTES SPÉCIALES",
          onTap: () {},
          content: const Center(
            child: Text(
              "CARTES SPÉCIALES",
              style: TextStyle(
                color: Color(0xFF424242),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 4,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 0.6,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildSpecialCard(
              'Joker',
              user.jokerCards,
              'lib/presentation/screens/exercice_uno/card_img/s4c.png',
            ),
            _buildSpecialCard(
              '+4',
              user.plus4Cards,
              'lib/presentation/screens/exercice_uno/card_img/s+4.png',
            ),
            _buildSpecialCard(
              'Reverse',
              user.reverseCards,
              'lib/presentation/screens/exercice_uno/card_img/binverse.png',
            ),
            _buildSpecialCard(
              'Skip',
              user.skipCards,
              'lib/presentation/screens/exercice_uno/card_img/vbloque.png',
            ),
          ],
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NumberCardFusionPage(userId: user.userId)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 2, 85, 173),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.science_outlined),
                SizedBox(width: 10),
                Text(
                  "Laboratoire de Fusion",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialCard(String name, int count, String imagePath) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const Icon(Icons.style, color: Colors.white, size: 40),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "x$count",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.greenAccent[400],
            shadows: const [
              Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 2),
            ],
          ),
        ),
      ],
    );
  }
}
