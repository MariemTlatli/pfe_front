import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/discovery_provider.dart';
import 'widgets/subject_header.dart';
import 'widgets/subject_list.dart';

class SubjectsScreen extends StatefulWidget {
  final String domainId;
  final String userId;

  const SubjectsScreen({
    Key? key,
    required this.domainId,
    required this.userId,
  }) : super(key: key);

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch subjects for this domain on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoveryProvider>().getSubjectsForDomain(widget.domainId);
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Image de background
        Image.asset(
          'assets/images/auth_bg.png', // ou Image.network('url')
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        // Overlay optionnel pour assombrir l'image
        Container(
          color: Colors.black.withOpacity(0.3), // Ajustez l'opacité
        ),
        // Contenu principal
        SafeArea(
          child: Column(
            children: [
              const SubjectHeader(),
              Expanded(
                child: SubjectList(userId: widget.userId),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}
