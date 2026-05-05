import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front/presentation/provider/discovery_provider.dart';
import 'package:front/presentation/screens/dashboard/widgets/domain_card.dart';
import 'package:front/presentation/screens/dashboard/widgets/subject_card.dart';

class DiscoveryPage extends StatefulWidget {
  final String userId;

  const DiscoveryPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  String? _selectedDomainId;

  // Définition des couleurs du thème
  static const Color _backgroundColor = Color(0xFFF5F7FA);
  static const Color _cardColor = Colors.white;
  static const Color _primaryColor = Color(0xFF6C63FF);
  static const Color _textPrimary = Color(0xFF2D3748);
  static const Color _textSecondary = Color(0xFF718096);
  static const Color _accentColor = Color(0xFF48BB78);

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<DiscoveryProvider>();
    final provider = notifier.state;

    // Spinner de chargement initial
    if (provider.isLoading && provider.domains.isEmpty) {
      return Container(
        color: _backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              ),
              const SizedBox(height: 16),
              Text(
                'Chargement des domaines...',
                style: TextStyle(color: _textSecondary, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Page d'erreur
    if (provider.error != null && provider.domains.isEmpty) {
      return Container(
        color: _backgroundColor,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Oups! Une erreur est survenue',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error ?? 'Erreur inconnue',
                  style: TextStyle(color: _textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: notifier.getDomains,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      color: _backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Header amélioré
            _buildHeader(),
            const SizedBox(height: 24),
            // Contenu principal
            Expanded(
              child: isMobile
                  ? _buildMobileLayout(context, provider, notifier)
                  : _buildDesktopLayout(context, provider, notifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 37, 87, 250),
            const Color.fromARGB(255, 34, 32, 70).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.explore, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ CORRECTION : Retirer le const et utiliser des guillemets doubles
                Text(
                  "Catalogue",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration:
                        TextDecoration.none, // ✅ Force pas de soulignement
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedDomainId == null
                      ? "Explorez nos domaines et découvrez de nouvelles matières"
                      : "Choisissez une matière pour commencer",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    decoration:
                        TextDecoration.none, // ✅ Force pas de soulignement
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    DiscoveryState provider,
    DiscoveryProvider notifier,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section des domaines
          _buildSectionTitle('Domaines', Icons.category),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: provider.domains.length,
              itemBuilder: (context, index) {
                final domain = provider.domains[index];
                final isSelected = _selectedDomainId == domain.id;
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  child: _buildDomainCardWrapper(
                    domain: domain,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() => _selectedDomainId = domain.id);
                      notifier.getSubjectsForDomain(domain.id);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          // Section des matières
          if (_selectedDomainId != null) ...[
            _buildSectionTitle('Matières dispofnibles', Icons.book),
            const SizedBox(height: 12),
            if (provider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (provider.currentDomainSubjects.isEmpty)
              _buildEmptyState('Aucune matière disponible dans ce domaine')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.currentDomainSubjects.length,
                itemBuilder: (context, index) {
                  final subject = provider.currentDomainSubjects[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: SubjectCard(
                      subject: subject,
                      isLoading: provider.isEnrolling,
                      onTap: () => _navigateToSubject(subject.id),
                      onEnroll: () =>
                          _handleEnroll(notifier, provider, subject.id),
                      userId: widget.userId,
                    ),
                  );
                },
              ),
          ] else
            _buildEmptyState('Sélectionnez un domaine pour voir les matières'),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    DiscoveryState provider,
    DiscoveryProvider notifier,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panneau latéral des domaines
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.category, color: _primaryColor, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Domaines',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: provider.domains.length,
                  itemBuilder: (context, index) {
                    final domain = provider.domains[index];
                    final isSelected = _selectedDomainId == domain.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: _buildDomainCardWrapper(
                        domain: domain,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() => _selectedDomainId = domain.id);
                          notifier.getSubjectsForDomain(domain.id);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Zone principale des matières
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.book, color: _accentColor, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Matières',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedDomainId != null &&
                          provider.currentDomainSubjects.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${provider.currentDomainSubjects.length} matière(s)',
                            style: TextStyle(
                              color: _accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _selectedDomainId == null
                      ? _buildEmptyState(
                          'Sélectionnez un domaine pour découvrir les matières',
                        )
                      : provider.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _primaryColor,
                            ),
                          ),
                        )
                      : provider.currentDomainSubjects.isEmpty
                      ? _buildEmptyState(
                          'Aucune matière disponible dans ce domaine',
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 1.6,
                              ),
                          itemCount: provider.currentDomainSubjects.length,
                          itemBuilder: (context, index) {
                            final subject =
                                provider.currentDomainSubjects[index];
                            return SubjectCard(
                              subject: subject,
                              isLoading: provider.isEnrolling,
                              onTap: () => _navigateToSubject(subject.id),
                              onEnroll: () =>
                                  _handleEnroll(notifier, provider, subject.id),
                              userId: widget.userId,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDomainCardWrapper({
    required dynamic domain,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: _primaryColor, width: 2)
            : Border.all(color: Colors.transparent, width: 2),
      ),
      child: DomainCard(domain: domain, onTap: onTap),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _primaryColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: _textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: _textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSubject(String subjectId) {
    Navigator.pushNamed(
      context,
      '/subject-detail',
      arguments: {'subjectId': subjectId, 'userId': widget.userId},
    );
  }

  Future<void> _handleEnroll(
    DiscoveryProvider notifier,
    DiscoveryState provider,
    String subjectId,
  ) async {
    final success = await notifier.enrollSubject(subjectId);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Inscription réussie!'),
            ],
          ),
          backgroundColor: _accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      _navigateToSubject(subjectId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Text('Erreur: ${provider.error ?? "Inconnue"}'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      notifier.clearError();
    }
  }
}
