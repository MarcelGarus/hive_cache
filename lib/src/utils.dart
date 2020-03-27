part of 'cache.dart';

extension SaveableEntity<E extends Entity<E>> on Entity<E> {
  void saveToCache() => HiveCache.put(this);
}

extension LoadableId<E extends Entity<E>> on Id<E> {
  E loadFromCache() => HiveCache.get(this);
}
