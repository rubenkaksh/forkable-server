import 'package:serverpod/serverpod.dart';

import '../errors/app_exceptions.dart';

/// Returns the authenticated user's identifier (UUID string under the
/// Serverpod 4 modular-auth stack) or throws [UnauthorizedException].
///
/// Use this at the top of every endpoint that requires a caller identity.
/// Never trust the client for authorization (plan §16).
String requireAuthenticatedUser(Session session) {
  final auth = session.authenticated;
  if (auth == null) {
    throw UnauthorizedException();
  }
  return auth.userIdentifier;
}
