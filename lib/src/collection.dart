part of 'cache.dart';

class Collection<E extends Entity<E>> {
  Collection({@required this.id, @required this.fetcher})
      : assert(id != null),
        assert(fetcher != null);

  final String id;
  final FutureOr<List<E>> Function() fetcher;
}

/// A wrapper around multiple [Id]s.
class _CollectionData<E extends Entity<E>>
    implements Entity<_CollectionData<E>> {
  _CollectionData({
    @required this.id,
    this.childrenIds = const [],
  })  : assert(id != null),
        assert(childrenIds != null);

  @override
  final Id<_CollectionData<E>> id;
  final List<Id<E>> childrenIds;

  int get typeId => HiveCache.typeIdByType<E>();

  @override
  bool operator ==(Object other) =>
      other is _CollectionData<E> &&
      id == other.id &&
      DeepCollectionEquality().equals(childrenIds, other.childrenIds);
  @override
  int get hashCode => hashList([id, childrenIds]);
}
