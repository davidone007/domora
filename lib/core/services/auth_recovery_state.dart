/// Holds the pending password-recovery flag.
///
/// Set to `true` when Supabase emits [AuthChangeEvent.passwordRecovery].
/// The GoRouter redirect uses this flag to intercept any navigation and
/// send the user to [AppConstants.routeResetPassword] instead.
/// Cleared automatically once the password has been updated (signedIn /
/// userUpdated event received while the flag is active).
class AuthRecoveryState {
  AuthRecoveryState._();
  static bool pendingRecovery = false;
}
