import 'dart:async';

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

typedef FetchById<E extends Entity<E>> = Future<E> Function(Id<E> id);

// ignore: non_constant_identifier_names
final HiveCache = HiveCacheImpl();

class HiveCacheImpl {
  /// Map from type ids of entites to [_Fetcher]s, which know how to fetch an
  /// entity of that type by its id.
  final _fetchers = <int, _Fetcher>{};
  Box<dynamic> _box;

  Future<E> fetch<E extends Entity<E>>(Id<E> id) {
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
    assert(_box == null, 'initialize was already called');
    await Hive.initFlutter();
    Hive
      ..registerAdapter(_AdapterForId())
      ..registerAdapter(_AdapterForIdCollectionData());
    _box = await Hive.openBox(boxName ?? 'cache');
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
  _IdCollectionData<dynamic> _createCollectionOfTypeId(
          int typeId, String id, List<String> children) =>
      _getFetcherOfTypeId(typeId)._createCollection(id, children);

  void put<E extends Entity<E>>(E entity) {
    _box.put(entity.id.value, entity);
  }

  E get<E extends Entity<E>>(Id<E> id) => _box.get(id.value) as E;
  Stream<E> getStreamed<E extends Entity<E>>(Id<E> id) {
    return _box.watch(key: id.value).map((event) => event.value).cast<E>();
  }
}

/// Class that knows how to fetch a certain type of entity.
@immutable
class _Fetcher<E extends Entity<E>> {
  const _Fetcher(this.fetch) : assert(fetch != null);

  final FetchById<E> fetch;

  Id<E> _createId(String id) => Id<E>(id);

  _IdCollectionData<E> _createCollection(String id, List<String> childrenIds) {
    return _IdCollectionData<E>(
      id: Id<_IdCollectionData<E>>(id),
      childrenIds: childrenIds.map((child) => Id<E>(child)).toList(),
    );
  }
}
