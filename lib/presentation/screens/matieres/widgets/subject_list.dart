import 'package:flutter/material.dart';
import 'package:front/presentation/provider/discovery_provider.dart';
import 'package:provider/provider.dart';
import 'subject_card_v2.dart';

class SubjectList extends StatelessWidget {
  final String userId;

  const SubjectList({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DiscoveryProvider>().state;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.currentDomainSubjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "Aucune matière trouvée",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: state.currentDomainSubjects.length,
      itemBuilder: (context, index) {
        final subject = state.currentDomainSubjects[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: SubjectCardV2(subject: subject, userId: userId),
        );
      },
    );
  }
}
