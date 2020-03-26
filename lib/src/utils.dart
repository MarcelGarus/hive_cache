part of 'cache.dart';

extension SaveableEntity<E extends Entity<E>> on Entity<E> {
  void saveToCache() => HiveCache.put(this);
}
