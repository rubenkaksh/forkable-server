import 'package:flutter/material.dart';
import 'package:server_base_client/server_base_client.dart';

import '../features/todos/todos_repository.dart';

/// Lists, creates, and completes the signed-in user's todos via
/// [TodosRepository]. Requires an authenticated session (the server rejects
/// unauthenticated calls) -- mount this inside a `SignInScreen`.
class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key, this.repository = const TodosRepository()});

  /// Overridable so tests can substitute a fake without a real server.
  final TodosRepository repository;

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> {
  final _textEditingController = TextEditingController();

  List<Todo>? _todos;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    try {
      final todos = await widget.repository.list();
      if (!mounted) return;
      setState(() {
        _todos = todos;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = '$e');
    }
  }

  Future<void> _createTodo() async {
    final title = _textEditingController.text.trim();
    if (title.isEmpty) return;

    try {
      await widget.repository.create(title);
      _textEditingController.clear();
      await _loadTodos();
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = '$e');
    }
  }

  Future<void> _completeTodo(Todo todo) async {
    try {
      await widget.repository.complete(todo.id!);
      await _loadTodos();
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final todos = _todos;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            key: const Key('todoTitleField'),
            controller: _textEditingController,
            onSubmitted: (_) => _createTodo(),
            decoration: InputDecoration(
              hintText: 'What needs doing?',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                key: const Key('addTodoButton'),
                onPressed: _createTodo,
                icon: const Icon(Icons.add),
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: switch (todos) {
              null => const Center(child: CircularProgressIndicator()),
              [] => const Center(child: Text('No todos yet.')),
              _ => ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return CheckboxListTile(
                    key: Key('todo-${todo.id}'),
                    value: todo.isDone,
                    onChanged: todo.isDone ? null : (_) => _completeTodo(todo),
                    title: Text(
                      todo.title,
                      style: todo.isDone
                          ? const TextStyle(
                              decoration: TextDecoration.lineThrough,
                            )
                          : null,
                    ),
                  );
                },
              ),
            },
          ),
        ],
      ),
    );
  }
}
