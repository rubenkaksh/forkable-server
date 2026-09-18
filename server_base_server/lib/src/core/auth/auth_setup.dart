import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'registration_rate_limiter.dart';

/// Rate limits for auth-sensitive endpoints (plan §17a).
class AuthRateLimits {
  final RateLimit failedLogin;
  final RateLimit passwordReset;
  final RateLimit registrationStart;

  const AuthRateLimits({
    required this.failedLogin,
    required this.passwordReset,
    required this.registrationStart,
  });

  /// Serverpod's own defaults (5 failed logins / 5 min, 3 password resets /
  /// hour) are already production-sensible.
  static const production = AuthRateLimits(
    failedLogin: RateLimit(maxAttempts: 5, timeframe: Duration(minutes: 5)),
    passwordReset: RateLimit(maxAttempts: 3, timeframe: Duration(hours: 1)),
    registrationStart: RateLimit(
      maxAttempts: 5,
      timeframe: Duration(minutes: 10),
    ),
  );

  /// A bit more headroom so repeated manual testing doesn't get locked out.
  static const development = AuthRateLimits(
    failedLogin: RateLimit(maxAttempts: 20, timeframe: Duration(minutes: 5)),
    passwordReset: RateLimit(maxAttempts: 10, timeframe: Duration(hours: 1)),
    registrationStart: RateLimit(
      maxAttempts: 20,
      timeframe: Duration(minutes: 10),
    ),
  );
}

/// Configures [AuthServices] (JWT + email sign-in) and
/// [RegistrationRateLimiter.instance] on [pod].
///
/// Shared between `server.dart` and tests that exercise the email identity
/// provider, so both stay wired the same way. Kept as simple in-memory-table
/// limits backed by Serverpod's own [DatabaseRateLimiter] -- no
/// Redis/gateway needed for this single-instance MVP (plan §17a, §22).
void configureAuthServices(
  Serverpod pod, {
  required AuthRateLimits rateLimits,

  /// Overrides for how verification codes are sent. Tests use this to
  /// capture codes instead of logging them, so they can drive a full
  /// registration/reset flow without a real mailbox. Production/development
  /// leave these null and get the Serverpod Cloud behavior (logged locally,
  /// emailed in staging/production).
  SendRegistrationVerificationCodeFunction? sendRegistrationVerificationCode,
  SendPasswordResetVerificationCodeFunction? sendPasswordResetVerificationCode,
}) {
  RegistrationRateLimiter.instance = RegistrationRateLimiter(
    rateLimits.registrationStart,
  );

  // The Serverpod Cloud config only provides the code-sending behavior
  // (logged locally in dev/test, emailed via Serverpod Cloud in
  // staging/production) and does not expose the rate-limit fields below, so
  // its send callbacks are reused directly on a config that does.
  final cloudEmailSending = ServerpodCloudEmailIdpConfig(
    appDisplayName: 'server_base',
  );

  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Use JWT for authentication keys towards the server.
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // Configure the email identity provider for email/password authentication.
      EmailIdpConfigFromPasswords(
        sendRegistrationVerificationCode:
            sendRegistrationVerificationCode ??
            cloudEmailSending.sendRegistrationVerificationCode,
        sendPasswordResetVerificationCode:
            sendPasswordResetVerificationCode ??
            cloudEmailSending.sendPasswordResetVerificationCode,
        failedLoginRateLimit: rateLimits.failedLogin,
        maxPasswordResetAttempts: rateLimits.passwordReset,
      ),
    ],
  );
}
