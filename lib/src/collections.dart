part of 'cache.dart';

class IdCollection<E extends Entity<E>> {
  IdCollection({@required this.id, @required this.fetcher})
      : assert(id != null),
        assert(fetcher != null);

  final Id<_IdCollectionData<E>> id;
  final FutureOr<List<E>> Function() fetcher;
}

/// A wrapper around multiple [Id]s.
class _IdCollectionData<E extends Entity<E>>
    implements Entity<_IdCollectionData<E>> {
  const _IdCollectionData({
    @required this.id,
    this.childrenIds = const [],
  })  : assert(id != null),
        assert(childrenIds != null);

  @override
  final Id<_IdCollectionData<E>> id;
  final List<Id<E>> childrenIds;

  int get typeId => HiveCache.typeIdByType<E>();
}
