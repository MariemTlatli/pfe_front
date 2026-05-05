import 'package:flutter/material.dart';
import '../../../../../presentation/provider/localization_provider.dart';

class LoginHeader extends StatelessWidget {
  final LocalizationProvider localizationProvider;

  const LoginHeader({Key? key, required this.localizationProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = localizationProvider.locale;
    return Column(
      children: [
        const SizedBox(height: 60),
        // Logo UNO Style circle
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Center(
            child: Text(
              "UNO",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          locale.welcome,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          locale.signIn,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
