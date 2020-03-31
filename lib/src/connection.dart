part of 'cache.dart';

class Connection<E extends Entity<E>> {
  Connection({@required this.id, @required this.fetcher})
      : assert(id != null),
        assert(fetcher != null);

  final String id;
  final FutureOr<E> Function() fetcher;
}

/// A wrapper around multiple [Id]s.
class _ConnectionData<E extends Entity<E>>
    implements Entity<_ConnectionData<E>> {
  _ConnectionData({
    @required this.id,
    this.connectedId,
  }) : assert(id != null);

  @override
  final Id<_ConnectionData<E>> id;
  final Id<E> connectedId;

  int get typeId => HiveCache.typeIdByType<E>();

  @override
  bool operator ==(Object other) =>
      other is _ConnectionData<E> &&
      id == other.id &&
      connectedId == other.connectedId;
  @override
  int get hashCode => hashList([id, connectedId]);
}
