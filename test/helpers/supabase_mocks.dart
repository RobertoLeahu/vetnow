import 'package:flutter_test/flutter_test.dart' show Fake;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Estado compartido entre los builders encadenados de Postgrest.
class PostgrestChainState {
  PostgrestChainState({this.result});

  dynamic result;
  Map<String, dynamic>? capturedInsert;
  String? eqColumn;
  Object? eqValue;
  bool deleteCalled = false;
  dynamic updateCalled;
}

Future<dynamic> _invokeThen(dynamic result, Invocation invocation) {
  final onValue = invocation.positionalArguments[0];
  final onError = invocation.namedArguments[#onError];
  var future = Future<dynamic>.value(result);
  if (onError != null) {
    future = future.catchError(onError as Function);
  }
  return future.then((value) => Function.apply(onValue, [value]));
}

class _FilterBuilder extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  _FilterBuilder(this.state);

  final PostgrestChainState state;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #then) {
      final value = state.result ?? <Map<String, dynamic>>[];
      return _invokeThen(value, invocation);
    }
    if (invocation.memberName == #insert) {
      state.capturedInsert = Map<String, dynamic>.from(
        invocation.positionalArguments[0] as Map,
      );
      return this;
    }
    if (invocation.memberName == #delete) {
      state.deleteCalled = true;
      return this;
    }
    if (invocation.memberName == #update) {
      state.updateCalled = invocation.positionalArguments[0];
      return this;
    }
    if (invocation.memberName == #eq) {
      state.eqColumn = invocation.positionalArguments[0] as String;
      state.eqValue = invocation.positionalArguments[1];
      return this;
    }
    if (invocation.memberName == #select) {
      if (state.capturedInsert != null) {
        return _TransformBuilder(state);
      }
      return this;
    }
    if (invocation.memberName == #single) {
      return _SingleBuilder(state);
    }
    return this;
  }
}

class _TransformBuilder extends Fake
    implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {
  _TransformBuilder(this.state);

  final PostgrestChainState state;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #then) {
      return _invokeThen(state.result, invocation);
    }
    if (invocation.memberName == #single) {
      return _SingleBuilder(state);
    }
    if (invocation.memberName == #select) {
      return this;
    }
    return this;
  }
}

class _SingleBuilder extends Fake
    implements PostgrestTransformBuilder<Map<String, dynamic>> {
  _SingleBuilder(this.state);

  final PostgrestChainState state;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #then) {
      return _invokeThen(state.result, invocation);
    }
    return this;
  }
}

/// Query builder falso para una tabla concreta.
class FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  FakeSupabaseQueryBuilder() : state = PostgrestChainState();

  final PostgrestChainState state;
  late final _FilterBuilder _filter = _FilterBuilder(state);

  Map<String, dynamic>? get capturedInsert => state.capturedInsert;
  bool get deleteCalled => state.deleteCalled;
  dynamic get updateCalled => state.updateCalled;

  PostgrestChainState get builder => state;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #insert ||
        invocation.memberName == #delete ||
        invocation.memberName == #update ||
        invocation.memberName == #select) {
      return _filter.noSuchMethod(invocation);
    }
    return super.noSuchMethod(invocation);
  }
}

/// Cliente Supabase falso con tablas registrables por nombre.
class FakeSupabaseClient extends Fake implements SupabaseClient {
  final Map<String, FakeSupabaseQueryBuilder> tables = {};

  FakeSupabaseQueryBuilder table(String name) =>
      tables.putIfAbsent(name, FakeSupabaseQueryBuilder.new);

  @override
  SupabaseQueryBuilder from(String table) => this.table(table);
}
