import 'package:server_base_server/src/core/errors/app_exceptions.dart';
import 'package:server_base_server/src/features/todos/todo_service.dart';
import 'package:server_base_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../../helpers/auth_helpers.dart';
import '../../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given Todo endpoint', (sessionBuilder, endpoints) {
    test(
      'when calling create unauthenticated then unauthorized error is thrown',
      () async {
        await expectLater(
          endpoints.todo.create(sessionBuilder, CreateTodoRequest(title: 'x')),
          throwsA(isA<UnauthorizedException>()),
        );
      },
    );

    test(
      'when calling create authenticated then todo is persisted for that user',
      () async {
        final builder = sessionBuilder.copyWith(
          authentication: authenticatedAs('user-1'),
        );
        final todo = await endpoints.todo.create(
          builder,
          CreateTodoRequest(title: '  Buy milk  '),
        );
        expect(todo.title, 'Buy milk');
        expect(todo.userId, 'user-1');
        expect(todo.isDone, isFalse);

        final listed = await endpoints.todo.list(builder);
        expect(listed, hasLength(1));
      },
    );

    test(
      'when creating todo with empty title then validation error is thrown',
      () async {
        final builder = sessionBuilder.copyWith(
          authentication: authenticatedAs('user-1'),
        );
        await expectLater(
          endpoints.todo.create(builder, CreateTodoRequest(title: '   ')),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test(
      'when completing another user\'s todo then forbidden error is thrown',
      () async {
        final owner = sessionBuilder.copyWith(
          authentication: authenticatedAs('user-1'),
        );
        final stranger = sessionBuilder.copyWith(
          authentication: authenticatedAs('user-2'),
        );
        final todo = await endpoints.todo.create(
          owner,
          CreateTodoRequest(title: 'secret task'),
        );

        await expectLater(
          endpoints.todo.complete(stranger, todo.id!),
          throwsA(isA<ForbiddenException>()),
        );
      },
    );

    test(
      'when completing own todo then todo is done',
      () async {
        final builder = sessionBuilder.copyWith(
          authentication: authenticatedAs('user-1'),
        );
        final todo = await endpoints.todo.create(
          builder,
          CreateTodoRequest(title: 'task'),
        );
        final done = await endpoints.todo.complete(builder, todo.id!);
        expect(done.isDone, isTrue);
      },
    );
  });

  withServerpod(
    'Given Todo createMany (transaction, rollback disabled for test harness)',
    (sessionBuilder, endpoints) {
      test(
        'when createMany includes an invalid request then nothing is persisted',
        () async {
          final builder = sessionBuilder.copyWith(
            authentication: authenticatedAs('user-1'),
          );
          final session = builder.build();
          await expectLater(
            TodoService(session).createMany(
              userId: 'user-1',
              requests: [
                CreateTodoRequest(title: 'valid'),
                CreateTodoRequest(title: ''),
              ],
            ),
            throwsA(isA<ValidationException>()),
          );
          final listed = await endpoints.todo.list(builder);
          expect(listed, isEmpty);
        },
      );
    },
    rollbackDatabase: RollbackDatabase.disabled,
  );
}
