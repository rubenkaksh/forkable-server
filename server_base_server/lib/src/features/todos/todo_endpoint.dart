import 'package:serverpod/serverpod.dart';

import '../../core/auth/auth.dart';
import '../../generated/protocol.dart';
import 'todo_service.dart';

/// Thin endpoint (plan §6): identity + delegation only.
class TodoEndpoint extends Endpoint {
  Future<Todo> create(Session session, CreateTodoRequest request) async {
    final userId = requireAuthenticatedUser(session);
    return TodoService(session).create(userId: userId, request: request);
  }

  Future<List<Todo>> list(Session session) async {
    final userId = requireAuthenticatedUser(session);
    return TodoService(session).list(userId: userId);
  }

  Future<Todo> complete(Session session, int todoId) async {
    final userId = requireAuthenticatedUser(session);
    return TodoService(session).complete(userId: userId, todoId: todoId);
  }
}
