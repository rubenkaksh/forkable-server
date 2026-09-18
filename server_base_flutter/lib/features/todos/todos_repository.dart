import 'package:server_base_client/server_base_client.dart';

import '../../client.dart';

/// Talks to the server `todos` endpoint through the generated typed client.
///
/// Auth: the generated client carries the auth key from the sign-in flow
/// (Serverpod 4 `authKeyProvider`), so calls require a signed-in user.
class TodosRepository {
  /// Const so callers can use it as a default constructor parameter while
  /// still substituting a fake in tests.
  const TodosRepository();

  /// Creates a todo for the signed-in user.
  Future<Todo> create(String title) =>
      client.todo.create(CreateTodoRequest(title: title));

  /// Lists the signed-in user's todos, newest first.
  Future<List<Todo>> list() => client.todo.list();

  /// Marks a todo done (owner only; server enforces authorization).
  Future<Todo> complete(int todoId) => client.todo.complete(todoId);
}
