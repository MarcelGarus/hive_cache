part of 'cache.dart';

extension ResolvedId<E extends Entity<E>> on Id<E> {
  StreamAndData<E, CachedFetchStreamData<dynamic>> resolve() {
    return FetchStream.create<E>(() => HiveCache.fetch(this)).cached(
      save: HiveCache.put,
      load: () => HiveCache.getStreamed(this),
    )..fetch();
  }
}

extension ResolvedIdCollection<E extends Entity<E>> on Collection<E> {
  Id<_CollectionData<E>> get _id => Id<_CollectionData<E>>(id);

  StreamAndData<List<Id<E>>, CachedFetchStreamData<dynamic>> resolve() {
    return FetchStream.create<List<Id<E>>>(() async {
      final entities = await this.fetcher();
      entities.forEach(HiveCache.put);
      return entities.map((entity) => entity.id).toList();
    }).cached(
      save: (ids) =>
          _CollectionData<E>(id: _id, childrenIds: ids).saveToCache(),
      load: () => HiveCache.get(_id),
    )..fetch();
  }
}

extension ResolvedIdList<E extends Entity<E>> on List<Id<E>> {
  Stream<List<E>> resolveAll() {
    return CombineLatestStream.list([
      for (final id in this) id.resolve()..fetch(),
    ]);
  }
}

extension ResolvedIdListStream<E extends Entity<E>>
    on StreamAndData<List<Id<E>>, CachedFetchStreamData<dynamic>> {
  StreamAndData<List<E>, CachedFetchStreamData<dynamic>> resolveAll() {
    return switchMap((ids) => ids.resolveAll());
  }
}

extension ResolvedIdConnection<E extends Entity<E>> on Connection<E> {
  Id<_ConnectionData<E>> get _id => Id<_ConnectionData<E>>(id);

  StreamAndData<Id<E>, CachedFetchStreamData<dynamic>> resolve() {
    return FetchStream.create<Id<E>>(() async {
      final entity = await fetcher()
        ..saveToCache();
      return entity.id;
    }).cached(
      save: (id) => _ConnectionData<E>(id: _id, connectedId: id).saveToCache(),
      load: () => HiveCache.get(_id),
    )..fetch();
  }
}

extension ResolvedIdStream<E extends Entity<E>>
    on StreamAndData<Id<E>, CachedFetchStreamData<dynamic>> {
  StreamAndData<E, CachedFetchStreamData<dynamic>> resolve() {
    return switchMap((id) => id.resolve());
  }
}
