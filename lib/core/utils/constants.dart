/// Constantes globales de la aplicación.
class AppConstants {
  AppConstants._();

  // ---------------------------------------------------------------------------
  // Tablas de Supabase
  // ---------------------------------------------------------------------------
  static const String tableUsers = 'users';
  static const String tableRoles = 'roles';
  static const String tableUserRoles = 'user_roles';
  static const String tableClientProfiles = 'client_profiles';
  static const String tableProviderProfiles = 'provider_profiles';
  static const String tableAddresses = 'addresses';
  static const String tableBookings = 'bookings';
  static const String tableReviews = 'reviews';
  static const String tableQuotes = 'quotes';
  static const String tablePayments = 'payments';

  // ---------------------------------------------------------------------------
  // Buckets
  // ---------------------------------------------------------------------------
  static const String bucketAvatars = 'avatars';

  // ---------------------------------------------------------------------------
  // Roles
  // ---------------------------------------------------------------------------
  static const String roleClient = 'client';
  static const String roleProvider = 'provider';

  // ---------------------------------------------------------------------------
  // Almacenamiento seguro
  // ---------------------------------------------------------------------------
  static const String storageKeyOnboardingDone = 'onboarding_done';
  static const String storageKeyUserRole = 'user_role';

  // ---------------------------------------------------------------------------
  // Rutas
  // ---------------------------------------------------------------------------
  static const String routeSplash = '/';
  static const String routeWelcome = '/welcome';
  static const String routeLogin = '/login';
  static const String routeSignup = '/signup';
  static const String routeOnboarding = '/onboarding';
  static const String routeClientHome = '/client-home';
  static const String routeProviderHome = '/provider-home';
  static const String routeProfile = '/profile';
  static const String routeProfileEdit = '/profile/edit';
  static const String routeMyServices = '/my-services';
  static const String routeServiceProposals = '/service-proposals';
  static const String routeForgotPassword = '/forgot-password';
  static const String routeResetPassword = '/reset-password';
}
