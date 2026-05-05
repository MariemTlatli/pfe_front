import 'package:flutter/material.dart';
import '../../../../../presentation/provider/auth_provider.dart';
import '../../../../../presentation/provider/localization_provider.dart';
import '../../../../../presentation/widgets/uno_button.dart';

class LoginFooter extends StatelessWidget {
  final AuthProvider authProvider;
  final LocalizationProvider localizationProvider;
  final VoidCallback onLogin;

  const LoginFooter({
    Key? key,
    required this.authProvider,
    required this.localizationProvider,
    required this.onLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = localizationProvider.locale;
    return Column(
      children: [
        const SizedBox(height: 30),
        UnoButton(
          label: locale.signIn.toUpperCase(),
          onPressed: onLogin,
          isLoading: authProvider.isLoading,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              locale.dontHaveAccount,
              style: const TextStyle(color: Colors.white70),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text(
                locale.register,
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
