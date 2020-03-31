part of 'cache.dart';

class EntityBuilder<E extends Entity<E>> extends StatelessWidget {
  const EntityBuilder({
    Key key,
    @required this.id,
    @required this.builder,
  }) : super(key: key);

  static ScopedBuilder raw<E extends Entity<E>>({
    Key key,
    @required Id<E> id,
    @required RawBuilder<E> builder,
  }) =>
      ScopedBuilder<StreamAndData<E, CachedFetchStreamData<dynamic>>>(
        create: () => id.resolve(),
        destroy: (stream) => stream.dispose(),
        builder: builder,
      );

  final Id<E> id;
  final FetchableBuilder<CacheSnapshot<E>> builder;

  @override
  Widget build(BuildContext context) {
    return EntityBuilder.raw<E>(
      id: id,
      builder: (_, stream) => CachedBuilder<E>(
        stream: stream.handleError(
          (error, stackTrace) => throw ErrorAndStacktrace(error, stackTrace),
        ),
        builder: builder,
      ),
    );
  }
}

class EntityListBuilder<E extends Entity<E>> extends StatelessWidget {
  const EntityListBuilder({
    Key key,
    @required this.ids,
    @required this.builder,
  }) : super(key: key);

  final List<Id<E>> ids;
  final FetchableBuilder<CacheSnapshot<List<E>>> builder;

  @override
  Widget build(BuildContext context) {
    return ScopedBuilder<
        StreamAndData<List<E>, CachedFetchStreamData<dynamic>>>(
      create: () => ids.resolveAll(),
      destroy: (stream) => stream.dispose(),
      builder: (_, stream) => CachedBuilder<List<E>>(
        stream: stream,
        builder: builder,
      ),
    );
  }
}

class CollectionBuilder<E extends Entity<E>> extends StatelessWidget {
  const CollectionBuilder({
    Key key,
    @required this.collection,
    @required this.builder,
  })  : assert(collection != null),
        assert(builder != null),
        super(key: key);

  static _PopulatedCollectionBuilder<E> populated<E extends Entity<E>>({
    Key key,
    @required Collection<E> collection,
    @required FetchableBuilder<CacheSnapshot<List<E>>> builder,
  }) =>
      _PopulatedCollectionBuilder(
          key: key, collection: collection, builder: builder);

  final Collection<E> collection;
  final FetchableBuilder<CacheSnapshot<List<Id<E>>>> builder;

  @override
  Widget build(BuildContext context) {
    return ScopedBuilder<
        StreamAndData<List<Id<E>>, CachedFetchStreamData<dynamic>>>(
      create: () => collection.resolve(),
      destroy: (stream) => stream.dispose(),
      builder: (_, streamOfIds) => CachedBuilder<List<Id<E>>>(
        stream: streamOfIds,
        builder: builder,
      ),
    );
  }
}

class _PopulatedCollectionBuilder<E extends Entity<E>> extends StatelessWidget {
  const _PopulatedCollectionBuilder({
    Key key,
    @required this.collection,
    @required this.builder,
  })  : assert(collection != null),
        assert(builder != null),
        super(key: key);

  final Collection<E> collection;
  final FetchableBuilder<CacheSnapshot<List<E>>> builder;

  @override
  Widget build(BuildContext context) {
    return ScopedBuilder<
        StreamAndData<List<E>, CachedFetchStreamData<dynamic>>>(
      create: () => collection.resolve().resolveAll(),
      destroy: (stream) => stream.dispose(),
      builder: (_, stream) => CachedBuilder<List<E>>(
        stream: stream,
        builder: builder,
      ),
    );
  }
}

class ConnectionBuilder<E extends Entity<E>> extends StatelessWidget {
  const ConnectionBuilder({
    Key key,
    @required this.connection,
    @required this.builder,
  })  : assert(connection != null),
        assert(builder != null),
        super(key: key);

  static _PopulatedConnectionBuilder<E> populated<E extends Entity<E>>({
    Key key,
    @required Connection<E> connection,
    @required FetchableBuilder<CacheSnapshot<E>> builder,
  }) =>
      _PopulatedConnectionBuilder(
          key: key, connection: connection, builder: builder);

  final Connection<E> connection;
  final FetchableBuilder<CacheSnapshot<Id<E>>> builder;

  @override
  Widget build(BuildContext context) {
    return ScopedBuilder<StreamAndData<Id<E>, CachedFetchStreamData<dynamic>>>(
      create: () => connection.resolve(),
      destroy: (stream) => stream.dispose(),
      builder: (_, stream) => CachedBuilder<Id<E>>(
        stream: stream,
        builder: builder,
      ),
    );
  }
}

class _PopulatedConnectionBuilder<E extends Entity<E>> extends StatelessWidget {
  const _PopulatedConnectionBuilder({
    Key key,
    @required this.connection,
    @required this.builder,
  })  : assert(connection != null),
        assert(builder != null),
        super(key: key);

  final Connection<E> connection;
  final FetchableBuilder<CacheSnapshot<E>> builder;

  @override
  Widget build(BuildContext context) {
    return ScopedBuilder<StreamAndData<E, CachedFetchStreamData<dynamic>>>(
      create: () => connection.resolve().resolve(),
      destroy: (stream) => stream.dispose(),
      builder: (_, stream) => CachedBuilder<E>(
        stream: stream,
        builder: builder,
      ),
    );
  }
}
