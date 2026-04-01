import 'localization_service.dart';

class AppLocalizationsFr extends AppLocalizations {
  @override
  String get appName => 'App Auth';

  @override
  String get welcome => 'Bienvenue';
  @override
  String get login => 'Connexion';
  @override
  String get register => 'Inscription';
  @override
  String get email => 'Email';
  @override
  String get password => 'Mot de passe';
  @override
  String get username => 'Nom d\'utilisateur';
  @override
  String get confirmPassword => 'Confirmer le mot de passe';
  @override
  String get forgotPassword => 'Mot de passe oublié ?';
  @override
  String get dontHaveAccount => 'Pas de compte ? ';
  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ? ';
  @override
  String get agree => 'J\'accepte les conditions et confidentialité';
  @override
  String get signIn => 'Se connecter';
  @override
  String get signUp => 'S\'inscrire';
  @override
  String get signOut => 'Se déconnecter';
  @override
  String get loading => 'Chargement...';
  @override
  String get error => 'Erreur';
  @override
  String get retry => 'Réessayer';
  @override
  String get cancel => 'Annuler';
  @override
  String get save => 'Enregistrer';
  @override
  String get delete => 'Supprimer';
  @override
  String get edit => 'Modifier';
  @override
  String get back => 'Retour';
  @override
  String get next => 'Suivant';
  @override
  String get skip => 'Ignorer';
  @override
  String get done => 'Terminé';

  // Validation Messages
  @override
  String get emailRequired => 'Email requis';
  @override
  String get emailInvalid => 'Format email invalide';
  @override
  String get passwordRequired => 'Mot de passe requis';
  @override
  String get passwordTooShort =>
      'Le mot de passe doit contenir au moins 6 caractères';
  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas';
  @override
  String get usernameRequired => 'Nom d\'utilisateur requis';
  @override
  String get usernameTooShort =>
      'Le nom d\'utilisateur doit contenir au moins 3 caractères';
  @override
  String get agreeTerms => 'Vous devez accepter les conditions';

  // API Messages
  @override
  String get networkError => 'Erreur réseau. Vérifiez votre connexion.';
  @override
  String get serverError => 'Erreur serveur. Veuillez réessayer plus tard.';
  @override
  String get unauthorizedError => 'Non autorisé. Veuillez vous reconnecter.';
  @override
  String get notFoundError => 'Ressource non trouvée.';
  @override
  String get validationError => 'Erreur de validation. Vérifiez vos données.';
  @override
  String get unknownError => 'Une erreur inconnue s\'est produite.';

  // Auth Messages
  @override
  String get loginSuccess => 'Connexion réussie';
  @override
  String get registerSuccess => 'Inscription réussie';
  @override
  String get logoutSuccess => 'Déconnexion réussie';
  @override
  String get invalidCredentials => 'Email ou mot de passe incorrect';
  @override
  String get emailAlreadyExists => 'Cet email est déjà enregistré';
  @override
  String get usernameAlreadyExists => 'Ce nom d\'utilisateur est déjà pris';

  // Home Screen
  @override
  String get home => 'Accueil';
  @override
  String get profile => 'Profil';
  @override
  String get settings => 'Paramètres';
  @override
  String get userInfo => 'Informations utilisateur';
  @override
  String get userId => 'ID utilisateur';
  @override
  String get userEmail => 'Email';
  @override
  String get tokenExpiration => 'Token expire dans';
  @override
  String get refresh => 'Actualiser';
}
