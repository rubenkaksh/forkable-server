import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import '../core/auth/registration_rate_limiter.dart';

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
class EmailIdpEndpoint extends EmailIdpBaseEndpoint {
  /// {@macro email_account_base_endpoint.start_registration}
  ///
  /// Rate-limited per email (plan §17a) -- see [RegistrationRateLimiter] for
  /// why this needs its own check on top of Serverpod's built-in limits.
  @override
  Future<UuidValue> startRegistration(
    final Session session, {
    required final String email,
  }) async {
    await RegistrationRateLimiter.instance.check(session, email: email);
    return super.startRegistration(session, email: email);
  }
}
