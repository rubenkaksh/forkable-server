
import 'package:serverpod_test/serverpod_test.dart';

/// Test helper: authenticated session builder override for [userId].
AuthenticationOverride authenticatedAs(String userId) =>
    AuthenticationOverride.authenticationInfo(userId, {});
