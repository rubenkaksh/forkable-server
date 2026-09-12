/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class Todo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Todo._({
    this.id,
    required this.userId,
    required this.title,
    required this.isDone,
    required this.createdAt,
  });

  factory Todo({
    int? id,
    required String userId,
    required String title,
    required bool isDone,
    required DateTime createdAt,
  }) = _TodoImpl;

  factory Todo.fromJson(Map<String, dynamic> jsonSerialization) {
    return Todo(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      title: jsonSerialization['title'] as String,
      isDone: _isc.BoolJsonExtension.fromJson(jsonSerialization['isDone']),
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String userId;

  String title;

  bool isDone;

  DateTime createdAt;

  /// Returns a shallow copy of this [Todo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Todo copyWith({
    int? id,
    String? userId,
    String? title,
    bool? isDone,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Todo',
      if (id != null) 'id': id,
      'userId': userId,
      'title': title,
      'isDone': isDone,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Todo',
      if (id != null) 'id': id,
      'userId': userId,
      'title': title,
      'isDone': isDone,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TodoImpl extends Todo {
  _TodoImpl({
    int? id,
    required String userId,
    required String title,
    required bool isDone,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userId: userId,
         title: title,
         isDone: isDone,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Todo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Todo copyWith({
    Object? id = _Undefined,
    String? userId,
    String? title,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return Todo(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
