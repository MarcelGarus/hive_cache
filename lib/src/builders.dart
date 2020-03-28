part of 'cache.dart';

typedef FetchCallback = Future<void> Function({bool force});

typedef RawBuilder<T> = Widget Function(
  BuildContext,
  StreamAndData<T, CachedFetchStreamData<dynamic>>,
);
typedef FetchableBuilder<T> = Widget Function(
  BuildContext,
  T,
  FetchCallback fetch,
);

class _ScopedBuilder<T> extends StatefulWidget {
  const _ScopedBuilder({
    Key key,
    @required this.create,
    @required this.destroy,
    @required this.builder,
  })  : assert(create != null),
        assert(destroy != null),
        assert(builder != null),
        super(key: key);

  final T Function() create;
  final void Function(T) destroy;
  final Widget Function(BuildContext, T) builder;

  @override
  State<StatefulWidget> createState() => _ScopedBuilderState<T>();
}

class _ScopedBuilderState<T> extends State<_ScopedBuilder<T>> {
  T object;

  @override
  void initState() {
    super.initState();
    object = widget.create();
  }

  @override
  void dispose() {
    widget.destroy(object);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, object);
}

class EntityBuilder<E extends Entity<E>> extends StatelessWidget {
  const EntityBuilder({
    Key key,
    @required this.id,
    @required this.builder,
  }) : super(key: key);

  static _ScopedBuilder raw<E extends Entity<E>>({
    Key key,
    @required Id<E> id,
    @required RawBuilder<E> builder,
  }) =>
      _ScopedBuilder<StreamAndData<E, CachedFetchStreamData<dynamic>>>(
        create: () => id.resolve(),
        destroy: (stream) => stream.dispose(),
        builder: builder,
      );

  final Id<E> id;
  final FetchableBuilder<AsyncSnapshot<E>> builder;

  @override
  Widget build(BuildContext context) {
    return EntityBuilder.raw<E>(
      id: id,
      builder: (_, stream) => StreamBuilder<E>(
        stream: stream,
        builder: (context, snapshot) => builder(
          context,
          snapshot,
          stream.fetch,
        ),
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
  final FetchableBuilder<AsyncSnapshot<List<E>>> builder;

  @override
  Widget build(BuildContext context) {
    return _ScopedBuilder<
        StreamAndData<List<E>, CachedFetchStreamData<dynamic>>>(
      create: () => ids.resolveAll(),
      destroy: (stream) => stream.dispose(),
      builder: (_, stream) => StreamBuilder<List<E>>(
        stream: stream,
        builder: (context, snapshot) => builder(
          context,
          snapshot,
          stream.fetch,
        ),
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
    @required FetchableBuilder<AsyncSnapshot<List<E>>> builder,
  }) =>
      _PopulatedCollectionBuilder(
          key: key, collection: collection, builder: builder);

  final Collection<E> collection;
  final FetchableBuilder<AsyncSnapshot<List<Id<E>>>> builder;

  @override
  Widget build(BuildContext context) {
    return _ScopedBuilder<
        StreamAndData<List<Id<E>>, CachedFetchStreamData<dynamic>>>(
      create: () => collection.resolve(),
      destroy: (stream) => stream.dispose(),
      builder: (_, streamOfIds) => StreamBuilder<List<Id<E>>>(
        stream: streamOfIds,
        builder: (context, snapshot) => builder(
          context,
          snapshot,
          streamOfIds.fetch,
        ),
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
  final FetchableBuilder<AsyncSnapshot<List<E>>> builder;

  @override
  Widget build(BuildContext context) {
    return _ScopedBuilder<
        StreamAndData<List<E>, CachedFetchStreamData<dynamic>>>(
      create: () => collection.resolve().resolveAll(),
      destroy: (stream) => stream.dispose(),
      builder: (_, stream) => StreamBuilder<List<E>>(
        stream: stream,
        builder: (context, snapshot) => builder(
          context,
          snapshot,
          stream.fetch,
        ),
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
    @required FetchableBuilder<AsyncSnapshot<E>> builder,
  }) =>
      _PopulatedConnectionBuilder(
          key: key, connection: connection, builder: builder);

  final Connection<E> connection;
  final FetchableBuilder<AsyncSnapshot<Id<E>>> builder;

  @override
  Widget build(BuildContext context) {
    return _ScopedBuilder<StreamAndData<Id<E>, CachedFetchStreamData<dynamic>>>(
      create: () => connection.resolve(),
      destroy: (stream) => stream.dispose(),
      builder: (_, stream) => StreamBuilder<Id<E>>(
        stream: stream,
        builder: (context, snapshot) => builder(
          context,
          snapshot,
          stream.fetch,
        ),
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
  final FetchableBuilder<AsyncSnapshot<E>> builder;

  @override
  Widget build(BuildContext context) {
    return _ScopedBuilder<StreamAndData<E, CachedFetchStreamData<dynamic>>>(
      create: () => connection.resolve().resolve(),
      destroy: (stream) => stream.dispose(),
      builder: (_, stream) => StreamBuilder<E>(
        stream: stream,
        builder: (context, snapshot) => builder(
          context,
          snapshot,
          stream.fetch,
        ),
      ),
    );
  }
}
