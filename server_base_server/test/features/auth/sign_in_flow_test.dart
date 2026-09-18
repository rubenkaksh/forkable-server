import 'package:server_base_server/src/core/auth/auth_setup.dart';
import 'package:server_base_server/src/core/errors/app_exceptions.dart';
import 'package:server_base_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:test/test.dart';

import '../../helpers/auth_helpers.dart';
import '../../integration/test_tools/serverpod_test_tools.dart';

// No point testing a rate limit here too -- rate_limit_test.dart already
// covers that. Keep the limits generous so a handful of sign-ups/logins in
// this file never trips them.
const _testRateLimits = AuthRateLimits(
  failedLogin: RateLimit(maxAttempts: 20, timeframe: Duration(minutes: 5)),
  passwordReset: RateLimit(maxAttempts: 20, timeframe: Duration(hours: 1)),
  registrationStart: RateLimit(
    maxAttempts: 20,
    timeframe: Duration(minutes: 10),
  ),
);

const _password = 'correct horse battery staple';

void main() {
  // The full sign-up/sign-in flow runs inside its own transaction/savepoint
  // (Serverpod's EmailIdp business layer), same as the rate limiter -- the
  // harness forbids nested implicit transactions.
  withServerpod(
    'Given email sign-in wired end to end',
    (sessionBuilder, endpoints) {
      String? registrationCode;

      setUpAll(() {
        configureAuthServices(
          Serverpod.instance,
          rateLimits: _testRateLimits,
          // Capture the code instead of logging it, so the test can drive
          // the full flow without a real mailbox.
          sendRegistrationVerificationCode:
              (
                session, {
                required email,
                required accountRequestId,
                required verificationCode,
                required transaction,
              }) {
                registrationCode = verificationCode;
              },
        );
      });

      /// Runs the real sign-up flow (start -> verify -> finish) end to end,
      /// exactly as the Flutter `SignInWidget` drives it, and returns the
      /// resulting session.
      Future<AuthSuccess> registerUser(String email) async {
        final requestId = await endpoints.emailIdp.startRegistration(
          sessionBuilder,
          email: email,
        );
        final registrationToken = await endpoints.emailIdp
            .verifyRegistrationCode(
              sessionBuilder,
              accountRequestId: requestId,
              verificationCode: registrationCode!,
            );
        return endpoints.emailIdp.finishRegistration(
          sessionBuilder,
          registrationToken: registrationToken,
          password: _password,
        );
      }

      test(
        'when calling a protected endpoint unauthenticated then the documented auth error is thrown',
        () async {
          await expectLater(
            endpoints.todo.create(
              sessionBuilder,
              CreateTodoRequest(title: 'x'),
            ),
            throwsA(isA<UnauthorizedException>()),
          );
        },
      );

      test(
        'when a new user signs up then their real identity authorizes protected calls',
        () async {
          final registered = await registerUser('signup-flow@example.com');
          final userId = registered.authUserId.toString();

          final authenticated = sessionBuilder.copyWith(
            authentication: authenticatedAs(userId),
          );
          final todo = await endpoints.todo.create(
            authenticated,
            CreateTodoRequest(title: 'first todo'),
          );

          // The user id flowing through requireAuthenticatedUser() is the
          // real one minted by registration, not a fabricated test id.
          expect(todo.userId, userId);
        },
      );

      test(
        'when signing in with the registered credentials then the same identity resolves',
        () async {
          const email = 'signin-flow@example.com';
          final registered = await registerUser(email);

          final loggedIn = await endpoints.emailIdp.login(
            sessionBuilder,
            email: email,
            password: _password,
          );

          expect(loggedIn.authUserId, registered.authUserId);
        },
      );

      test(
        'when refreshing with the issued refresh token then a new access token for the same user is issued',
        () async {
          final registered = await registerUser('refresh-flow@example.com');
          expect(
            registered.refreshToken,
            isNotNull,
            reason: 'sign-up should issue a refresh token to persist',
          );

          final refreshed = await endpoints.jwtRefresh.refreshAccessToken(
            sessionBuilder,
            refreshToken: registered.refreshToken,
          );

          expect(refreshed.authUserId, registered.authUserId);
          expect(refreshed.token, isNot(equals(registered.token)));
        },
      );

      test(
        'when refreshing with an invalid refresh token then access is not granted',
        () async {
          await expectLater(
            endpoints.jwtRefresh.refreshAccessToken(
              sessionBuilder,
              refreshToken: 'not-a-real-refresh-token',
            ),
            throwsA(anything),
          );
        },
      );
    },
    rollbackDatabase: RollbackDatabase.disabled,
  );
}
