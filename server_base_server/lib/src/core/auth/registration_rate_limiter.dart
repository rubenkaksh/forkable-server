import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../errors/app_exceptions.dart';

/// Rate-limits requests to start email sign-up (plan §17a).
///
/// Serverpod's built-in email identity provider already rate-limits failed
/// logins, password-reset requests, and verification-code guessing (see
/// [EmailIdpConfig.failedLoginRateLimit] and
/// [EmailIdpConfig.maxPasswordResetAttempts]), but not the initial
/// registration request itself -- nothing stops repeated calls from sending
/// unlimited verification emails to (or on behalf of) the same address. This
/// closes that gap using the same [DatabaseRateLimiter] building block
/// Serverpod uses internally, rather than introducing new infrastructure.
class RegistrationRateLimiter {
  /// The instance configured at startup in `server.dart`.
  static late final RegistrationRateLimiter instance;

  final DatabaseRateLimiter _limiter;

  RegistrationRateLimiter(RateLimit limit)
    : _limiter = DatabaseRateLimiter(
        RateLimiterConfig(
          domain: 'email',
          source: 'registration_start',
          maxAttempts: limit.maxAttempts,
          timeframe: limit.timeframe,
        ),
      );

  /// Throws [TooManyRequestsException] if [email] has exceeded the limit.
  Future<void> check(Session session, {required String email}) async {
    if (!await _limiter.tryRecordAttempt(session, key: email)) {
      session.log(
        'Rate limit exceeded for email sign-up start ($email).',
        level: LogLevel.warning,
      );
      throw TooManyRequestsException(
        message: 'Too many sign-up attempts for this email. Try again later.',
      );
    }
  }
}
