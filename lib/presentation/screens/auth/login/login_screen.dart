import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../presentation/provider/auth_provider.dart';
import '../../../../presentation/provider/localization_provider.dart';
import '../../../../presentation/widgets/custom_button.dart';
import '../../../../presentation/widgets/custom_text_field.dart';
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
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Consumer2<AuthProvider, LocalizationProvider>(
              builder: (context, authProvider, localizationProvider, _) {
                final locale = localizationProvider.locale;

                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Text(locale.welcome, style: AppTextStyles.displaySmall),
                      const SizedBox(height: 8),
                      Text(
                        locale.signIn,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Email Field
                      CustomTextField(
                        label: locale.email,
                        hint: 'example@email.com',
                        controller: _emailController,
                        prefixIcon: const Icon(Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return locale.emailRequired;
                          }
                          if (!RegExp(
                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                          ).hasMatch(value!)) {
                            return locale.emailInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Password Field
                      CustomTextField(
                        label: locale.password,
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return locale.passwordRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implement forgot password
                          },
                          child: Text(locale.forgotPassword),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Error Message
                      if (authProvider.errorMessage != null) ...[
                        CustomErrorWidget(message: authProvider.errorMessage!),
                        const SizedBox(height: 24),
                      ],

                      // Sign In Button
                      CustomButton(
                        label: locale.signIn,
                        isLoading: authProvider.isLoading,
                        onPressed: () {
                          authProvider.clearError();
                          if (_formKey.currentState!.validate()) {
                            authProvider
                                .login(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                )
                                .then((success) {
                                  if (success && mounted) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/home',
                                    );
                                  }
                                });
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(locale.dontHaveAccount),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: Text(
                              locale.register,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
