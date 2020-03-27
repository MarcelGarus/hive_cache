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

class _RawEntityBuilder<E extends Entity<E>> extends StatefulWidget {
  const _RawEntityBuilder({Key key, @required this.id, @required this.builder})
      : assert(id != null),
        assert(builder != null),
        super(key: key);

  final Id<E> id;
  final RawBuilder<E> builder;

  @override
  State<StatefulWidget> createState() => _RawEntityBuilderState<E>();
}

class _RawEntityBuilderState<E extends Entity<E>>
    extends State<_RawEntityBuilder<E>> {
  StreamAndData<E, CachedFetchStreamData<dynamic>> stream;

  @override
  void initState() {
    super.initState();
    stream = widget.id.resolve();
    stream.fetch();
  }

  @override
  void dispose() {
    stream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, stream);
}

class EntityBuilder<E extends Entity<E>> extends StatelessWidget {
  const EntityBuilder({
    Key key,
    @required this.id,
    @required this.builder,
  }) : super(key: key);

  static _RawEntityBuilder raw<E extends Entity<E>>({
    Key key,
    @required Id<E> id,
    @required RawBuilder<E> builder,
  }) =>
      _RawEntityBuilder<E>(id: id, builder: builder);

  final Id<E> id;
  final FetchableBuilder<AsyncSnapshot<E>> builder;

  @override
  Widget build(BuildContext context) {
    return _RawEntityBuilder<E>(
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

class CollectionBuilder<E extends Entity<E>> extends StatefulWidget {
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
  _CollectionBuilderState<E> createState() => _CollectionBuilderState<E>();
}

class _CollectionBuilderState<E extends Entity<E>>
    extends State<CollectionBuilder<E>> {
  StreamAndData<List<Id<E>>, CachedFetchStreamData<dynamic>> stream;

  @override
  void initState() {
    super.initState();
    stream = widget.collection.resolve();
  }

  @override
  void dispose() {
    stream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Id<E>>>(
      stream: stream,
      builder: (context, snapshot) => widget.builder(
        context,
        snapshot,
        stream.fetch,
      ),
    );
  }
}

class _PopulatedCollectionBuilder<E extends Entity<E>> extends StatefulWidget {
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
  _PopulatedCollectionBuilderState<E> createState() =>
      _PopulatedCollectionBuilderState<E>();
}

class _PopulatedCollectionBuilderState<E extends Entity<E>>
    extends State<_PopulatedCollectionBuilder<E>> {
  StreamAndData<List<E>, CachedFetchStreamData<dynamic>> stream;

  @override
  void initState() {
    super.initState();
    stream = widget.collection.resolve().resolveAll();
  }

  @override
  void dispose() {
    stream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<E>>(
      stream: stream,
      builder: (context, snapshot) => widget.builder(
        context,
        snapshot,
        stream.fetch,
      ),
    );
  }
}

class ConnectionBuilder<E extends Entity<E>> extends StatefulWidget {
  const ConnectionBuilder({
    Key key,
    @required this.connection,
    @required this.builder,
  })  : assert(connection != null),
        assert(builder != null),
        super(key: key);

  static _PopulatedConnectionBuilder<E> populated<E extends Entity<E>>({
    Key key,
    @required Connection<E> collection,
    @required FetchableBuilder<AsyncSnapshot<E>> builder,
  }) =>
      _PopulatedConnectionBuilder(
          key: key, collection: collection, builder: builder);

  final Connection<E> connection;
  final FetchableBuilder<AsyncSnapshot<Id<E>>> builder;

  @override
  _ConnectionBuilderState<E> createState() => _ConnectionBuilderState<E>();
}

class _ConnectionBuilderState<E extends Entity<E>>
    extends State<ConnectionBuilder<E>> {
  StreamAndData<Id<E>, CachedFetchStreamData<dynamic>> stream;

  @override
  void initState() {
    super.initState();
    stream = widget.connection.resolve();
  }

  @override
  void dispose() {
    stream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Id<E>>(
      stream: stream,
      builder: (context, snapshot) => widget.builder(
        context,
        snapshot,
        stream.fetch,
      ),
    );
  }
}

class _PopulatedConnectionBuilder<E extends Entity<E>> extends StatefulWidget {
  const _PopulatedConnectionBuilder({
    Key key,
    @required this.collection,
    @required this.builder,
  })  : assert(collection != null),
        assert(builder != null),
        super(key: key);

  final Connection<E> collection;
  final FetchableBuilder<AsyncSnapshot<E>> builder;

  @override
  _PopulatedConnectionBuilderState<E> createState() =>
      _PopulatedConnectionBuilderState<E>();
}

class _PopulatedConnectionBuilderState<E extends Entity<E>>
    extends State<_PopulatedConnectionBuilder<E>> {
  StreamAndData<E, CachedFetchStreamData<dynamic>> stream;

  @override
  void initState() {
    super.initState();
    stream = widget.collection.resolve().resolve();
  }

  @override
  void dispose() {
    stream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<E>(
      stream: stream,
      builder: (context, snapshot) => widget.builder(
        context,
        snapshot,
        stream.fetch,
      ),
    );
  }
}
