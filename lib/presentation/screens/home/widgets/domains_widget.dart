import 'package:flutter/material.dart';
import 'package:front/data/models/domain_model.dart';
import 'package:front/presentation/provider/discovery_provider.dart';
import 'package:front/presentation/provider/auth_provider.dart';
import 'package:front/presentation/widgets/uno_card.dart';
import 'package:provider/provider.dart';


class DomainsWidget extends StatelessWidget {
  const DomainsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DiscoveryProvider>().state;

    if (state.isLoading && state.domains.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.domains.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: UnoCard(
            height: 45,
            width: 220,
            label: 'EXPLORER LES DOMAINES',
            onTap: () {}, // Optional action
            content: const Center(
              child: Text(
                "LES DOMAINES",
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
        const SizedBox(height: 15),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 24, right: 8),
            itemCount: state.domains.length,
            itemBuilder: (context, index) {
              final domain = state.domains[index];
              return _buildDomainCard(context, domain);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDomainCard(BuildContext context, DomainModel domain) {
    final color = _getDomainColor(domain.name);

    return GestureDetector(
      onTap: () {
        final userId = context.read<AuthProvider>().userId ?? '';
        Navigator.pushNamed(
          context,
          '/subjects',
          arguments: {'domainId': domain.id, 'userId': userId},
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16, bottom: 8, top: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Image (UNO Card)
              Positioned.fill(
                child: Image.asset(
                  'assets/images/carte.png',
                  fit: BoxFit.cover,
                ),
              ),
              
              // Dark Gradient Overlay for readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   
                    Text(
                      domain.name.toUpperCase(),
                      textAlign: TextAlign.center,

                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${domain.subjectsCount} MATIÈRES",
                        style: const TextStyle(
                          color: Color(0xFF8E0000),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDomainColor(String name) {    
    return Colors.indigoAccent;
  }

}
