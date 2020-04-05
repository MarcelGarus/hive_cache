import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'adapters.dart';
part 'builders.dart';
part 'collection.dart';
part 'id_and_entity.dart';
part 'resolve.dart';
part 'utils.dart';
part 'connection.dart';

typedef FetchById<E extends Entity<E>> = Future<E> Function(Id<E> id);

// ignore: non_constant_identifier_names
final HiveCache = HiveCacheImpl();

class HiveCacheImpl {
  /// Map from type ids of entites to [_Fetcher]s, which know how to fetch an
  /// entity of that type by its [Id].
  final _fetchers = <int, _Fetcher>{};

  /// Whether [TypeAdapter]s for HiveCache-types like [Id], [Collection] and
  /// [Connection] have been registered at [Hive].
  var _adaptersRegistered = false;

  /// The [Box] that contains all the cached data.
  Box<dynamic> _box;
  bool get isInitialized => _box != null;

  Future<E> _fetch<E extends Entity<E>>(Id<E> id) {
    final fetcher = _fetchers.values
        .whereType<_Fetcher<E>>()
        .singleWhere((_) => true, orElse: () => null);

    if (fetcher == null) {
      throw UnsupportedError("We don't know how to fetch $E. Are you sure you "
          'registered the type $E?');
    }

    return fetcher.fetch(id);
  }

  Future<void> initialize([String boxName]) async {
    assert(!isInitialized, 'initialize was already called');
    boxName ??= 'cache';

    await Hive.initFlutter();
    if (!_adaptersRegistered) {
      Hive
        ..registerAdapter(_AdapterForId())
        ..registerAdapter(_AdapterForIdCollectionData())
        ..registerAdapter(_AdapterForIdConnectionData());
      _adaptersRegistered = true;
    }

    _box = await Hive.openBox(boxName);
  }

  Future<void> clear([String boxName]) async {
    await _box?.close();
    _box = null;
    await Hive.deleteBoxFromDisk(boxName ?? 'cache');
    await initialize(boxName);
  }

  void registerEntityType<E extends Entity<E>>(
      TypeAdapter<E> adapter, FetchById<E> fetch) {
    final typeId = adapter.typeId;
    assert(_fetchers[typeId] == null,
        'A fetcher with typeId $typeId is already registered');
    _fetchers[typeId] = _Fetcher<E>(fetch);
    registerAdapter(adapter);
  }

  void registerAdapter<T>(TypeAdapter<T> adapter) {
    Hive.registerAdapter(adapter);
  }

  int typeIdByType<E extends Entity<E>>() {
    try {
      return _fetchers.entries
          .singleWhere((entry) => entry.value is _Fetcher<E>)
          .key;
      // Unlike Exceptions, Errors indicate that the programmer did something
      // wrong. Generally, they should not be caught during runtime. In this
      // case, however, we throw another Error with more information, so it's
      // okay to catch the error here.
      // ignore: avoid_catching_errors
    } on StateError {
      throw UnsupportedError('No id for type $E found. Did you forget to '
          'register the type $E?');
    }
  }

  _Fetcher<dynamic> _getFetcherOfTypeId(int id) =>
      _fetchers[id] ?? (throw UnsupportedError('Unknown type id $id.'));
  Id<dynamic> _createIdOfTypeId(int typeId, String id) =>
      _getFetcherOfTypeId(typeId)._createId(id);
  _CollectionData<dynamic> _createCollectionOfTypeId(
          int typeId, String id, List<String> children) =>
      _getFetcherOfTypeId(typeId)._createCollection(id, children);
  _ConnectionData<dynamic> _createConnectionOfTypeId(
          int typeId, String id, String connectedId) =>
      _getFetcherOfTypeId(typeId)._createConnection(id, connectedId);

  void _put<E extends Entity<E>>(E entity) {
    _box.put(entity.id.value, entity);
  }

  Stream<E> _get<E extends Entity<E>>(Id<E> id) async* {
    final initialValue = _box.get(id.value);
    if (initialValue != null) {
      yield initialValue;
    }

    await for (final event in _box.watch(key: id.value)) {
      yield event.value as E;
    }
  }
}

/// Class that knows how to fetch a certain type of entity.
@immutable
class _Fetcher<E extends Entity<E>> {
  const _Fetcher(this.fetch) : assert(fetch != null);

  final FetchById<E> fetch;

  Id<E> _createId(String id) => Id<E>(id);

  _CollectionData<E> _createCollection(String id, List<String> childrenIds) {
    return _CollectionData<E>(
      id: Id<_CollectionData<E>>(id),
      childrenIds: childrenIds.map((child) => Id<E>(child)).toList(),
    );
  }

  _ConnectionData<E> _createConnection(String id, String connectedId) {
    return _ConnectionData(
      id: Id<_ConnectionData<E>>(id),
      connectedId: Id<E>.orNull(connectedId),
    );
  }
}
