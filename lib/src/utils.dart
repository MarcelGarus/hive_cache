part of 'cache.dart';

extension SaveableEntity<E extends Entity<E>> on Entity<E> {
  void saveToCache() => HiveCache._put(this);
}

extension SaveableEntities<E extends Entity<E>> on List<Entity<E>> {
  void saveAllToCache() {
    for (final entity in this) {
      entity.saveToCache();
    }
  }
}

extension LoadableId<E extends Entity<E>> on Id<E> {
  Stream<E> loadFromCache() => HiveCache._get<E>(this);
}
