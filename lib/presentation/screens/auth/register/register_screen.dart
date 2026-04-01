import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../presentation/provider/auth_provider.dart';
import '../../../../presentation/provider/localization_provider.dart';
import '../../../../presentation/widgets/custom_button.dart';
import '../../../../presentation/widgets/custom_text_field.dart';
import '../../../../presentation/widgets/error_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _agreeToTerms = false;

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
                      const SizedBox(height: 30),
                      Text(locale.register, style: AppTextStyles.displaySmall),
                      const SizedBox(height: 8),
                      Text(
                        locale.signUp,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Username Field
                      CustomTextField(
                        label: locale.username,
                        controller: _usernameController,
                        prefixIcon: const Icon(Icons.person_outlined),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return locale.usernameRequired;
                          }
                          if (value!.length < 3) {
                            return locale.usernameTooShort;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

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
                          if (value!.length < 6) {
                            return locale.passwordTooShort;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Confirm Password Field
                      CustomTextField(
                        label: locale.confirmPassword,
                        controller: _confirmPasswordController,
                        obscureText: !_showConfirmPassword,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _showConfirmPassword = !_showConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return locale.passwordMismatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Terms Checkbox
                      CheckboxListTile(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                        title: Text(
                          locale.agree,
                          style: AppTextStyles.bodySmall,
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 24),

                      // Error Message
                      if (authProvider.errorMessage != null) ...[
                        CustomErrorWidget(message: authProvider.errorMessage!),
                        const SizedBox(height: 24),
                      ],

                      // Sign Up Button
                      CustomButton(
                        label: locale.signUp,
                        isLoading: authProvider.isLoading,
                        isEnabled: _agreeToTerms,
                        onPressed: () {
                          authProvider.clearError();
                          if (_formKey.currentState!.validate()) {
                            authProvider
                                .register(
                                  username: _usernameController.text.trim(),
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

                      // Sign In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(locale.alreadyHaveAccount),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              locale.login,
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
