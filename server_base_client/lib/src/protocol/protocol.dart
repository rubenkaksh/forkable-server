/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:server_base_client/src/protocol/features/todos/todo.dart'
    as _iubzkgdj;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'features/greetings/greeting.dart' as _iabash66;
import 'features/todos/create_todo_request.dart' as _iaxr2c1j;
import 'features/todos/todo.dart' as _ibpzld66;
export 'features/greetings/greeting.dart';
export 'features/todos/create_todo_request.dart';
export 'features/todos/todo.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iabash66.Greeting) {
      return _iabash66.Greeting.fromJson(data) as T;
    }
    if (t == _iaxr2c1j.CreateTodoRequest) {
      return _iaxr2c1j.CreateTodoRequest.fromJson(data) as T;
    }
    if (t == _ibpzld66.Todo) {
      return _ibpzld66.Todo.fromJson(data) as T;
    }
    if (t == _isc.getType<_iabash66.Greeting?>()) {
      return (data != null ? _iabash66.Greeting.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iaxr2c1j.CreateTodoRequest?>()) {
      return (data != null ? _iaxr2c1j.CreateTodoRequest.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ibpzld66.Todo?>()) {
      return (data != null ? _ibpzld66.Todo.fromJson(data) : null) as T;
    }
    if (t == List<_iubzkgdj.Todo>) {
      return (data as List).map((e) => deserialize<_iubzkgdj.Todo>(e)).toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iabash66.Greeting => 'Greeting',
      _iaxr2c1j.CreateTodoRequest => 'CreateTodoRequest',
      _ibpzld66.Todo => 'Todo',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('server_base.', '');
    }

    switch (data) {
      case _iabash66.Greeting():
        return 'Greeting';
      case _iaxr2c1j.CreateTodoRequest():
        return 'CreateTodoRequest';
      case _ibpzld66.Todo():
        return 'Todo';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_iabash66.Greeting>(data['data']);
    }
    if (dataClassName == 'CreateTodoRequest') {
      return deserialize<_iaxr2c1j.CreateTodoRequest>(data['data']);
    }
    if (dataClassName == 'Todo') {
      return deserialize<_ibpzld66.Todo>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('server_base', this);
    _iacc.Protocol().registerHostProtocol('server_base', this);
  }

  @override
  String getModuleName() => 'server_base';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
