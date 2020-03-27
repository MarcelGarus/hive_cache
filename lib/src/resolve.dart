part of 'cache.dart';

extension ResolvedId<E extends Entity<E>> on Id<E> {
  StreamAndData<E, CachedFetchStreamData<E>> resolve() {
    return FetchStream.create<E>(() => HiveCache.fetch(this)).cached(
      save: HiveCache.put,
      load: () => HiveCache.getStreamed(this),
    );
  }
}

extension ResolvedIdCollection<E extends Entity<E>> on IdCollection<E> {
  Id<_IdCollectionData<E>> get _id => Id<_IdCollectionData<E>>(id);

  StreamAndData<List<Id<E>>, CachedFetchStreamData<dynamic>> resolve() {
    return FetchStream.create<List<Id<E>>>(() async {
      final entities = await this.fetcher();
      entities.forEach(HiveCache.put);
      return entities.map((entity) => entity.id).toList();
    }).cached(
      save: (ids) =>
          _IdCollectionData<E>(id: _id, childrenIds: ids).saveToCache(),
      load: () => HiveCache.get(_id),
    );
  }
}

extension ResolvedIdList<E extends Entity<E>> on List<Id<E>> {
  Stream<List<E>> resolveAll() {
    return CombineLatestStream.list([
      for (final id in this) HiveCache.getStreamed<E>(id),
    ]);
  }
}

extension ResolvedIdListStream<E extends Entity<E>>
    on StreamAndData<List<Id<E>>, CachedFetchStreamData<dynamic>> {
  StreamAndData<List<E>, CachedFetchStreamData<dynamic>> resolveAll() {
    return switchMap((ids) => ids.resolveAll());
  }
}
