import 'package:serverpod/serverpod.dart';

import '../../core/errors/app_exceptions.dart';
import '../../generated/protocol.dart';

/// Business rules for the todos feature (plan §7).
class TodoService {
  TodoService(this.session);

  final Session session;

  Future<Todo> create({
    required String userId,
    required CreateTodoRequest request,
  }) async {
    final title = request.title.trim();
    if (title.isEmpty) {
      throw ValidationException(message: 'Title must not be empty');
    }
    if (title.length > 200) {
      throw ValidationException(
        message: 'Title must be at most 200 characters',
      );
    }

    final todo = Todo(
      userId: userId,
      title: title,
      isDone: false,
      createdAt: DateTime.now().toUtc(),
    );
    return Todo.db.insertRow(session, todo);
  }

  Future<List<Todo>> list({required String userId}) {
    return Todo.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.createdAt.desc(),
    );
  }

  /// Marks a todo done. Only the owner may do this (plan §17 inline authz).
  Future<Todo> complete({
    required String userId,
    required int todoId,
  }) async {
    final todo = await Todo.db.findById(session, todoId);
    if (todo == null) {
      throw NotFoundException(message: 'Todo $todoId not found');
    }
    if (todo.userId != userId) {
      throw ForbiddenException(message: 'Not your todo');
    }
    todo.isDone = true;
    return Todo.db.updateRow(session, todo);
  }

  /// Atomically creates several todos in one transaction (plan §15).
  /// If any request is invalid, nothing is persisted.
  Future<List<Todo>> createMany({
    required String userId,
    required List<CreateTodoRequest> requests,
  }) async {
    // Validate first so an invalid request aborts before any write.
    final titles = requests.map((r) => r.title.trim()).toList();
    if (titles.any((t) => t.isEmpty)) {
      throw ValidationException(message: 'Title must not be empty');
    }
    if (titles.any((t) => t.length > 200)) {
      throw ValidationException(
        message: 'Title must be at most 200 characters',
      );
    }

    return session.db.transaction((transaction) async {
      final todos = <Todo>[];
      for (final title in titles) {
        todos.add(
          await Todo.db.insertRow(
            session,
            Todo(
              userId: userId,
              title: title,
              isDone: false,
              createdAt: DateTime.now().toUtc(),
            ),
            transaction: transaction,
          ),
        );
      }
      return todos;
    });
  }
}
