import 'package:flutter/material.dart';
import 'package:front/data/models/subject_model.dart';
import 'package:front/presentation/provider/discovery_provider.dart';
import 'package:provider/provider.dart';

class EnrollButton extends StatelessWidget {
  final SubjectModel subject;
  final String userId;

  const EnrollButton({
    Key? key,
    required this.subject,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<DiscoveryProvider>();
    final isEnrolling = context.watch<DiscoveryProvider>().state.isEnrolling;

    if (subject.isEnrolled) {
      return OutlinedButton.icon(
        onPressed: () => _navigateToSubject(context),
        icon: const Icon(Icons.check, size: 18),
        label: const Text("INSCRIT"),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.green,
          side: const BorderSide(color: Colors.green),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
    }

    return ElevatedButton(
      onPressed: isEnrolling ? null : () => _handleEnroll(context, notifier),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: isEnrolling
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Text("S'INSCRIRE"),
    );
  }

  Future<void> _handleEnroll(BuildContext context, DiscoveryProvider notifier) async {
    final success = await notifier.enrollSubject(subject.id);
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inscription à ${subject.name} réussie !'),
          backgroundColor: Colors.green,
        ),
      );
      _navigateToSubject(context);
    } else {
      final error = notifier.state.error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${error ?? "Inconnue"}'),
          backgroundColor: Colors.red,
        ),
      );
      notifier.clearError();
    }
  }

  void _navigateToSubject(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/subject-detail',
      arguments: {'subjectId': subject.id, 'userId': userId},
    );
  }
}
