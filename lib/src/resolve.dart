part of 'cache.dart';

extension ResolvedId<E extends Entity<E>> on Id<E> {
  StreamAndData<E, CachedFetchStreamData<dynamic>> resolve() {
    return FetchStream.create<E>(() => HiveCache._fetch(this)).cached(
      save: (entity) => entity?.saveToCache(),
      load: this == null ? () => Stream.value(null) : loadFromCache,
    )..fetch();
  }
}

extension ResolvedIdCollection<E extends Entity<E>> on Collection<E> {
  Id<_CollectionData<E>> get _id => Id<_CollectionData<E>>(id);

  StreamAndData<List<Id<E>>, CachedFetchStreamData<dynamic>> resolve() {
    assert(this != null);

    return FetchStream.create<List<Id<E>>>(() async {
      final entities = await this.fetcher();
      entities.saveAllToCache();

      return entities.map((entity) => entity.id).toList();
    }).cached(
      save: (ids) =>
          _CollectionData<E>(id: _id, childrenIds: ids).saveToCache(),
      load: () => _id.loadFromCache().map((data) => data.childrenIds),
    )..fetch();
  }
}

extension ResolvedIdList<E extends Entity<E>> on List<Id<E>> {
  StreamAndData<List<E>, CachedFetchStreamData<dynamic>> resolveAll() {
    assert(this != null);

    return FetchStream.create(() async {
      return Future.wait([
        for (final id in this) id.resolve().first,
      ]);
    }).cached(
      save: (entities) => entities?.saveAllToCache(),
      load: () => CombineLatestStream.list([
        for (final id in this) id.loadFromCache(),
      ]),
    )..fetch();
  }
}

extension ResolvedIdListStream<E extends Entity<E>>
    on StreamAndData<List<Id<E>>, CachedFetchStreamData<dynamic>> {
  StreamAndData<List<E>, CachedFetchStreamData<dynamic>> resolveAll() {
    assert(this != null);

    return FetchStream.create(() async {
      fetch(force: true);
      return await (await first)?.resolveAll()?.first;
    }).cached(
      save: (entities) => entities?.saveAllToCache(),
      load: () => switchMap(
        (ids) => ids == null ? Stream.value(null) : ids.resolveAll(),
      ),
    )..fetch();
  }
}

extension ResolvedConnection<E extends Entity<E>> on Connection<E> {
  Id<_ConnectionData<E>> get _id => Id<_ConnectionData<E>>(id);

  StreamAndData<Id<E>, CachedFetchStreamData<dynamic>> resolve() {
    assert(this != null);

    return FetchStream.create<Id<E>>(() async {
      final entity = await fetcher();

      entity?.saveToCache();
      return entity?.id;
    }).cached(
      save: (id) => _ConnectionData<E>(id: _id, connectedId: id).saveToCache(),
      load: () => _id.loadFromCache().map((data) => data.connectedId),
    )..fetch();
  }
}

extension ResolvedIdStream<E extends Entity<E>>
    on StreamAndData<Id<E>, CachedFetchStreamData<dynamic>> {
  StreamAndData<E, CachedFetchStreamData<dynamic>> resolve() {
    assert(this != null);

    return FetchStream.create(() async {
      fetch(force: true);
      return await (await first).resolve().first;
    }).cached(
      save: (entity) => entity?.saveToCache(),
      load: () =>
          switchMap((id) => id == null ? Stream.value(null) : id.resolve()),
    )..fetch();
  }
}
