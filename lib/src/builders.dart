part of 'cache.dart';

typedef FetchCallback = Future<void> Function({bool force});

typedef RawBuilder<E extends Entity<E>> = Widget Function(
  BuildContext,
  StreamAndData<E, CachedFetchStreamData<dynamic>>,
);
typedef FetchableBuilder<E extends Entity<E>> = Widget Function(
  BuildContext,
  AsyncSnapshot<E>,
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
  final FetchableBuilder<E> builder;

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

typedef FetchableCollectionBuilder<E extends Entity<E>> = Widget Function(
  BuildContext,
  AsyncSnapshot<List<Id<E>>>,
  FetchCallback fetch,
);

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
    @required IdCollection<E> collection,
    @required FetchablePopulatedCollectionBuilder<E> builder,
  }) =>
      _PopulatedCollectionBuilder(
          key: key, collection: collection, builder: builder);

  final IdCollection<E> collection;
  final FetchableCollectionBuilder<E> builder;

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

typedef FetchablePopulatedCollectionBuilder<E extends Entity<E>> = Widget
    Function(
  BuildContext,
  AsyncSnapshot<List<E>>,
  FetchCallback fetch,
);

class _PopulatedCollectionBuilder<E extends Entity<E>> extends StatefulWidget {
  const _PopulatedCollectionBuilder({
    Key key,
    @required this.collection,
    @required this.builder,
  })  : assert(collection != null),
        assert(builder != null),
        super(key: key);

  final IdCollection<E> collection;
  final FetchablePopulatedCollectionBuilder<E> builder;

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
