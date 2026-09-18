import 'package:serverpod/serverpod.dart';

/// Base class for typed application exceptions.
///
/// Subclasses are serialized to the generated client automatically by
/// Serverpod (they appear in the generated protocol). Catch them on the
/// client to display typed errors instead of generic failures.
abstract class AppException extends SerializableException {
  String get description;
}

/// Thrown when the caller is not authenticated (401-equivalent).
class UnauthorizedException extends AppException {
  final String message;

  UnauthorizedException({this.message = 'Authentication required'});

  @override
  String get description => message;
}

/// Thrown when an authenticated caller lacks permission (403-equivalent).
class ForbiddenException extends AppException {
  final String message;

  ForbiddenException({this.message = 'Not allowed'});

  @override
  String get description => message;
}

/// Thrown when a referenced resource does not exist (404-equivalent).
class NotFoundException extends AppException {
  final String message;

  NotFoundException({this.message = 'Not found'});

  @override
  String get description => message;
}

/// Thrown when input fails validation (422-equivalent).
class ValidationException extends AppException {
  final String message;

  ValidationException({this.message = 'Invalid input'});

  @override
  String get description => message;
}

/// Thrown when an operation conflicts with current state (409-equivalent).
class ConflictException extends AppException {
  final String message;

  ConflictException({this.message = 'Conflict'});

  @override
  String get description => message;
}

/// Thrown when a caller exceeds a rate limit (429-equivalent).
class TooManyRequestsException extends AppException {
  final String message;

  TooManyRequestsException({this.message = 'Too many requests'});

  @override
  String get description => message;
}
