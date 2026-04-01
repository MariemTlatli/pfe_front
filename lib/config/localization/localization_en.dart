import 'localization_service.dart';

class AppLocalizationsEn extends AppLocalizations {
  @override
  String get appName => 'Auth App';

  @override
  String get welcome => 'Welcome';
  @override
  String get login => 'Login';
  @override
  String get register => 'Register';
  @override
  String get email => 'Email';
  @override
  String get password => 'Password';
  @override
  String get username => 'Username';
  @override
  String get confirmPassword => 'Confirm Password';
  @override
  String get forgotPassword => 'Forgot Password?';
  @override
  String get dontHaveAccount => 'Don\'t have an account? ';
  @override
  String get alreadyHaveAccount => 'Already have an account? ';
  @override
  String get agree => 'I agree to the terms and conditions';
  @override
  String get signIn => 'Sign In';
  @override
  String get signUp => 'Sign Up';
  @override
  String get signOut => 'Sign Out';
  @override
  String get loading => 'Loading...';
  @override
  String get error => 'Error';
  @override
  String get retry => 'Retry';
  @override
  String get cancel => 'Cancel';
  @override
  String get save => 'Save';
  @override
  String get delete => 'Delete';
  @override
  String get edit => 'Edit';
  @override
  String get back => 'Back';
  @override
  String get next => 'Next';
  @override
  String get skip => 'Skip';
  @override
  String get done => 'Done';

  // Validation Messages
  @override
  String get emailRequired => 'Email is required';
  @override
  String get emailInvalid => 'Invalid email format';
  @override
  String get passwordRequired => 'Password is required';
  @override
  String get passwordTooShort => 'Password must be at least 6 characters';
  @override
  String get passwordMismatch => 'Passwords do not match';
  @override
  String get usernameRequired => 'Username is required';
  @override
  String get usernameTooShort => 'Username must be at least 3 characters';
  @override
  String get agreeTerms => 'You must agree to the terms and conditions';

  // API Messages
  @override
  String get networkError => 'Network error. Please check your connection.';
  @override
  String get serverError => 'Server error. Please try again later.';
  @override
  String get unauthorizedError => 'Unauthorized. Please login again.';
  @override
  String get notFoundError => 'Resource not found.';
  @override
  String get validationError => 'Validation error. Please check your input.';
  @override
  String get unknownError => 'An unknown error occurred.';

  // Auth Messages
  @override
  String get loginSuccess => 'Login successful';
  @override
  String get registerSuccess => 'Registration successful';
  @override
  String get logoutSuccess => 'Logout successful';
  @override
  String get invalidCredentials => 'Invalid email or password';
  @override
  String get emailAlreadyExists => 'This email is already registered';
  @override
  String get usernameAlreadyExists => 'This username is already taken';

  // Home Screen
  @override
  String get home => 'Home';
  @override
  String get profile => 'Profile';
  @override
  String get settings => 'Settings';
  @override
  String get userInfo => 'User Information';
  @override
  String get userId => 'User ID';
  @override
  String get userEmail => 'Email';
  @override
  String get tokenExpiration => 'Token Expires In';
  @override
  String get refresh => 'Refresh';
}
