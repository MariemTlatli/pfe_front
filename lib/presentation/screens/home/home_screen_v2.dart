import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../presentation/provider/localization_provider.dart';
import 'widgets/profile_widget.dart';
import 'widgets/domains_widget.dart';
import '../../widgets/uno_card.dart';

class HomeScreenV2 extends StatelessWidget {
  const HomeScreenV2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, LocalizationProvider>(
      builder: (context, authProvider, localizationProvider, _) {
        final userId = authProvider.userId ?? '';
        final locale = localizationProvider.locale;

        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/auth_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    floating: true,
                    title: const Text(
                      'DASHBOARD',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    centerTitle: true,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () => _showLogoutDialog(context),
                      ),
                    ],
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 10),
                      // 🌐 DOMAINS SECTION
                      const DomainsWidget(),
                      const SizedBox(height: 20),
                      
                      // 👤 PROFIL SECTION
                      ProfileWidget(userId: userId),
                      
                      // 📚 ACTIONS SECTION
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            _buildActionCard(
                              context,
                              title: "CATALOGUE",
                              subtitle: "Découvre toutes tes leçons",
                              icon: Icons.auto_stories_rounded,
                              color: Colors.amber,
                              onTap: () => Navigator.pushNamed(context, '/discovery', arguments: userId),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return UnoCard(
      height: 100,
      onTap: onTap,
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)],
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF424242),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.black26, size: 16),
          ],
        ),
      ), label: '',
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
        content: const Text('Voulez-vous vraiment vous déconnecter ?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Non')),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout().then((_) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              });
            },
            child: const Text('Oui', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
