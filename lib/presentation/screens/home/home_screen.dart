import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../presentation/provider/auth_provider.dart';
import '../../../presentation/provider/localization_provider.dart';
import '../../../config/theme/colors.dart';
import '../../../config/theme/text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: () => _showLogoutDialog(context),
              ),
              PopupMenuItem(
                child: const Text('Settings'),
                onTap: () {
                  // Navigate to settings
                },
              ),
            ],
          ),
        ],
      ),
      body: Consumer2<AuthProvider, LocalizationProvider>(
        builder: (context, authProvider, localizationProvider, _) {
          final locale = localizationProvider.locale;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: Text(
                            (authProvider.username != null &&
                                    authProvider.username!.isNotEmpty)
                                ? authProvider.username!
                                      .substring(0, 1)
                                      .toUpperCase()
                                : '?',
                            style: AppTextStyles.displaySmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${locale.welcome}, ${authProvider.username}!',
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                authProvider.email ?? '',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // NOUVEAU : Bouton d'accès au Catalogue
                  const Text(
                    'Apprentissage',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.school),
                      label: const Text('Acceder au Catalogue'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        // Passer l'ID utilisateur
                        final userId = authProvider.userId ?? '';
                        Navigator.pushNamed(
                          context,
                          '/discovery',
                          arguments: userId,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.school),
                      label: const Text('Acceder au success page'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        // Passer l'ID utilisateur
                        final userId = authProvider.userId ?? '';
                        Navigator.pushNamed(context, '/success');
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // User Info Section
                  Text('Informations', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'ID Utilisateur',
                            authProvider.userId ?? 'N/A',
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Nom d\'utilisateur',
                            authProvider.username ?? 'N/A',
                          ),
                          const Divider(height: 24),
                          _buildInfoRow('Email', authProvider.email ?? 'N/A'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Language Selection
                  Text('Langue', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: localizationProvider.supportedLanguages.map((
                      lang,
                    ) {
                      final isSelected =
                          localizationProvider.currentLocale.languageCode ==
                          lang;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              localizationProvider.changeLanguage(lang);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? AppColors.primary
                                  : AppColors.grey200,
                            ),
                            child: Text(
                              lang.toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Se deconnecter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      onPressed: () => _showLogoutDialog(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey600),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deconnexion'),
        content: const Text('Etes-vous sur de vouloir vous deconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout().then((_) {
                Navigator.pushReplacementNamed(context, '/login');
              });
            },
            child: const Text('Deconnexion'),
          ),
        ],
      ),
    );
  }
}
