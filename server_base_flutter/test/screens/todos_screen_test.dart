import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:server_base_client/server_base_client.dart';
import 'package:server_base_flutter/features/todos/todos_repository.dart';
import 'package:server_base_flutter/screens/todos_screen.dart';

/// In-memory fake standing in for the real network-backed [TodosRepository]
/// (no server/auth needed to exercise the screen).
class FakeTodosRepository implements TodosRepository {
  final List<Todo> _todos;
  var _nextId = 1;

  FakeTodosRepository([List<Todo>? initialTodos]) : _todos = initialTodos ?? [];

  @override
  Future<Todo> create(String title) async {
    final todo = Todo(
      id: _nextId++,
      userId: 'test-user',
      title: title,
      isDone: false,
      createdAt: DateTime(2026),
    );
    _todos.insert(0, todo);
    return todo;
  }

  @override
  Future<List<Todo>> list() async => List.unmodifiable(_todos);

  @override
  Future<Todo> complete(int todoId) async {
    final todo = _todos.firstWhere((t) => t.id == todoId);
    todo.isDone = true;
    return todo;
  }
}

void main() {
  testWidgets('lists existing todos on load', (tester) async {
    final repository = FakeTodosRepository([
      Todo(
        id: 1,
        userId: 'test-user',
        title: 'Buy milk',
        isDone: false,
        createdAt: DateTime(2026),
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TodosScreen(repository: repository)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.text('No todos yet.'), findsNothing);
  });

  testWidgets(
    'creating a todo through the text field adds it to the list',
    (tester) async {
      final repository = FakeTodosRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TodosScreen(repository: repository)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No todos yet.'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('todoTitleField')),
        'Walk the dog',
      );
      await tester.tap(find.byKey(const Key('addTodoButton')));
      await tester.pumpAndSettle();

      expect(find.text('Walk the dog'), findsOneWidget);
      expect(find.text('No todos yet.'), findsNothing);
    },
  );

  testWidgets('completing a todo marks it done and disables the checkbox', (
    tester,
  ) async {
    final repository = FakeTodosRepository([
      Todo(
        id: 1,
        userId: 'test-user',
        title: 'Buy milk',
        isDone: false,
        createdAt: DateTime(2026),
      ),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TodosScreen(repository: repository)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('todo-1')));
    await tester.pumpAndSettle();

    final checkbox = tester.widget<CheckboxListTile>(
      find.byKey(const Key('todo-1')),
    );
    expect(checkbox.value, isTrue);
    expect(checkbox.onChanged, isNull);
  });
}
