import 'package:server_base_server/src/core/auth/auth_setup.dart';
import 'package:server_base_server/src/core/errors/app_exceptions.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:test/test.dart';

import '../../integration/test_tools/serverpod_test_tools.dart';

// Rate-limiting is checked before the account/request lookup on every path
// exercised here, so a made-up email is enough -- no account or in-flight
// request needs to exist for the limiter to trigger (plan §17a).
const _testRateLimits = AuthRateLimits(
  failedLogin: RateLimit(maxAttempts: 3, timeframe: Duration(minutes: 5)),
  passwordReset: RateLimit(maxAttempts: 3, timeframe: Duration(hours: 1)),
  registrationStart: RateLimit(
    maxAttempts: 3,
    timeframe: Duration(minutes: 10),
  ),
);

void main() {
  // The rate limiter records each attempt in its own transaction, separate
  // from the endpoint's own -- the harness forbids nested implicit
  // transactions, same as the todos createMany transaction test.
  withServerpod(
    'Given email auth configured with test rate limits',
    (sessionBuilder, endpoints) {
      setUpAll(() {
        configureAuthServices(Serverpod.instance, rateLimits: _testRateLimits);
      });

      test(
        'when failed logins exceed the limit then too many attempts is thrown',
        () async {
          const email = 'rate-limit-login@example.com';

          for (var i = 0; i < _testRateLimits.failedLogin.maxAttempts; i++) {
            await expectLater(
              endpoints.emailIdp.login(
                sessionBuilder,
                email: email,
                password: 'wrong-password',
              ),
              throwsA(isA<EmailAccountLoginException>()),
            );
          }

          await expectLater(
            endpoints.emailIdp.login(
              sessionBuilder,
              email: email,
              password: 'wrong-password',
            ),
            throwsA(
              isA<EmailAccountLoginException>().having(
                (e) => e.reason,
                'reason',
                EmailAccountLoginExceptionReason.tooManyAttempts,
              ),
            ),
          );
        },
      );

      test(
        'when password reset requests exceed the limit then too many attempts is thrown',
        () async {
          const email = 'rate-limit-reset@example.com';

          for (var i = 0; i < _testRateLimits.passwordReset.maxAttempts; i++) {
            // Unregistered emails resolve without error (never leak account
            // existence); the attempt still counts toward the limit.
            await endpoints.emailIdp.startPasswordReset(
              sessionBuilder,
              email: email,
            );
          }

          await expectLater(
            endpoints.emailIdp.startPasswordReset(sessionBuilder, email: email),
            throwsA(
              isA<EmailAccountPasswordResetException>().having(
                (e) => e.reason,
                'reason',
                EmailAccountPasswordResetExceptionReason.tooManyAttempts,
              ),
            ),
          );
        },
      );

      test(
        'when sign-up start requests exceed the limit then too many requests is thrown',
        () async {
          const email = 'rate-limit-signup@example.com';

          for (
            var i = 0;
            i < _testRateLimits.registrationStart.maxAttempts;
            i++
          ) {
            await endpoints.emailIdp.startRegistration(
              sessionBuilder,
              email: email,
            );
          }

          await expectLater(
            endpoints.emailIdp.startRegistration(sessionBuilder, email: email),
            throwsA(isA<TooManyRequestsException>()),
          );
        },
      );
    },
    rollbackDatabase: RollbackDatabase.disabled,
  );
}
