import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../presentation/provider/auth_provider.dart';
import '../../../../presentation/provider/localization_provider.dart';
import 'widgets/login_header.dart';
import 'widgets/login_form.dart';
import 'widgets/login_footer.dart';
import '../../../../presentation/widgets/error_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          // Assurez-vous que le chemin correspond à l'endroit où vous avez sauvegardé l'image
          image: AssetImage('assets/images/auth_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor:
            Colors.transparent, // Important pour voir l'image en dessous
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Consumer2<AuthProvider, LocalizationProvider>(
                builder: (context, auth, loc, _) {
                  return Column(
                    children: [
                      LoginHeader(localizationProvider: loc),
                      const SizedBox(height: 40),
                      LoginForm(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        formKey: _formKey,
                        localizationProvider: loc,
                      ),
                      if (auth.errorMessage != null) ...[
                        const SizedBox(height: 20),
                        CustomErrorWidget(message: auth.errorMessage!),
                      ],
                      LoginFooter(
                        authProvider: auth,
                        localizationProvider: loc,
                        onLogin: () => _handleLogin(auth),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin(AuthProvider auth) {
    auth.clearError();
    if (_formKey.currentState!.validate()) {
      auth
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          )
          .then((success) {
            if (success && mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
