part of 'cache.dart';

extension SaveableEntity<E extends Entity<E>> on Entity<E> {
  void saveToCache() {
    assert(this != null);
    HiveCache._put(this);
  }
}

extension SaveableEntities<E extends Entity<E>> on Iterable<Entity<E>> {
  void saveAllToCache() {
    assert(this != null);
    for (final entity in this) {
      assert(entity != null);
      entity.saveToCache();
    }
  }
}

extension LoadableId<E extends Entity<E>> on Id<E> {
  Stream<E> loadFromCache() {
    assert(this != null);
    return HiveCache._get<E>(this);
  }
}
