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
  StreamAndData<List<Id<E>>, CachedFetchStreamData<dynamic>> resolve() {
    return FetchStream.create<List<Id<E>>>(() async {
      final entities = await this.fetcher();
      entities.forEach(HiveCache.put);
      return entities.map((entity) => entity.id).toList();
    }).cached(
      save: (ids) =>
          HiveCache.put(_IdCollectionData<E>(id: this.id, childrenIds: ids)),
      load: () => HiveCache.get(this.id),
    );
  }

  StreamAndData<List<E>, CachedFetchStreamData<dynamic>> resolvePopulated() {
    return FetchStream.create<List<E>>(fetcher).cached(
      save: (entities) {
        entities.forEach(HiveCache.put);
        final ids = entities.map((entity) => entity.id).toList();
        _IdCollectionData(id: id, childrenIds: ids).saveToCache();
      },
      load: () {
        final streamOfIds = HiveCache.getStreamed<_IdCollectionData<E>>(id)
            .map((collection) => collection.childrenIds);

        return streamOfIds.switchMap((ids) {
          return CombineLatestStream.list([
            for (final id in ids) HiveCache.getStreamed<E>(id),
          ]);
        });
      },
    );
  }
}
