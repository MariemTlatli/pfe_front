import 'package:flutter/material.dart';
import '../../../../../presentation/provider/localization_provider.dart';
import '../../../../../presentation/widgets/uno_text_field.dart';

class LoginForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final LocalizationProvider localizationProvider;

  const LoginForm({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
    required this.localizationProvider,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final locale = widget.localizationProvider.locale;
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          UnoTextField(
            label: locale.email,
            hint: 'example@email.com',
            controller: widget.emailController,
            prefixIcon: const Icon(Icons.email_outlined, color: Colors.white),
            validator: (value) {
              if (value?.isEmpty ?? true) return locale.emailRequired;
              if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value!)) {
                return locale.emailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          UnoTextField(
            label: locale.password,
            controller: widget.passwordController,
            prefixIcon: const Icon(Icons.lock_outlined, color: Colors.white),
            obscureText: !_showPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return locale.passwordRequired;
              return null;
            },
          ),
        ],
      ),
    );
  }
}
