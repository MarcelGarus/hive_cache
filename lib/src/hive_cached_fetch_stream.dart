part of 'cache.dart';

typedef LoadFromSyncCache<T> = T Function();

extension HiveCached<E extends Entity<E>> on FetchStream<E> {
  HiveCachedFetchStream<E> hiveCached() {}
}

/// A broadcast [Stream] that wraps a [FetchStream] by saving and loading the
/// data to/from a cache using a [SaveToCache] and a [LoadToCache] function.
/// Only actually calls [fetch] on the original [FetchStream] if necessary.
abstract class HiveCachedFetchStream<T> extends FetchStream<T> {
  HiveCachedFetchStream._() : super.raw();

  factory HiveCachedFetchStream.impl(
    FetchStream<T> parent,
    SaveToCache<T> saveToCache,
    LoadFromSyncCache<T> loadFromSyncCache,
    LoadFromCache<T> loadFromStreamedCache,
  ) = _HiveCachedFetchStreamImpl<T>;

  Future<void> fetch({bool force = false});
  void dispose();

  @override
  HiveCachedFetchStream<E> asyncExpand<E>(
          Stream<E> Function(T event) convert) =>
      super.asyncExpand(convert)._asHiveCached(fetch, dispose);

  @override
  HiveCachedFetchStream<E> asyncMap<E>(FutureOr<E> Function(T event) convert) =>
      super.asyncMap(convert)._asHiveCached(fetch, dispose);

  @override
  HiveCachedFetchStream<R> cast<R>() =>
      super.cast<R>()._asHiveCached(fetch, dispose);

  @override
  HiveCachedFetchStream<T> distinct(
          [bool Function(T previous, T next) equals]) =>
      super.distinct(equals)._asHiveCached(fetch, dispose);

  @override
  HiveCachedFetchStream<S> expand<S>(Iterable<S> Function(T element) convert) =>
      super.expand(convert)._asHiveCached(fetch, dispose);

  @override
  HiveCachedFetchStream<T> handleError(Function onError,
          {bool Function(dynamic error) test}) =>
      super.handleError(onError, test: test)._asHiveCached(fetch, dispose);

  @override
  HiveCachedFetchStream<S> map<S>(S Function(T event) convert) =>
      super.map(convert)._asHiveCached(fetch, dispose);

  @override
  HiveCachedFetchStream<T> skip(int count) =>
      super.skip(count)._asHiveCached(fetch, dispose);

  @override
  HiveCachedFetchStream<T> skipWhile(bool Function(T element) test) =>
      super.skipWhile(test)._asHiveCached(fetch, dispose);

  @override
  HiveCachedFetchStream<T> take(int count) =>
      super.take(count)._asHiveCached(fetch, dispose);

  @override
  HiveCachedFetchStream<T> takeWhile(bool Function(T element) test) =>
      super.takeWhile(test)._asHiveCached(fetch, dispose);

  @override
  HiveCachedFetchStream<T> timeout(Duration timeLimit,
          {void Function(EventSink<T> sink) onTimeout}) =>
      super.timeout(timeLimit)._asHiveCached(fetch, dispose);

  @override
  HiveCachedFetchStream<S> transform<S>(
          StreamTransformer<T, S> streamTransformer) =>
      super.transform(streamTransformer)._asHiveCached(fetch, dispose);

  @override
  HiveCachedFetchStream<T> where(bool Function(T event) test) =>
      super.where(test)._asHiveCached(fetch, dispose);
}

class _HiveCachedFetchStreamImpl<T> extends HiveCachedFetchStream<T> {
  _HiveCachedFetchStreamImpl(this._parent, this._saveToCache,
      this._loadFromSyncCache, this._loadFromStreamedCache)
      : super._() {
    // Whenever a new value got fetched, it gets saved to the cache.
    _parent.listen((value) {
      _controller.add(value);
      _saveToCache(value);
      _loadingFromCache?.cancel();
      _loadingFromCache = _loadFromStreamedCache().listen(_controller.add);
    }, onError: (error, stackTrace) {
      _controller.addError(error, stackTrace);
    }, onDone: _controller.close);
  }

  final _controller = BehaviorSubject();
  final FetchStream<T> _parent;
  final SaveToCache<T> _saveToCache;
  final LoadFromSyncCache<T> _loadFromSyncCache;
  final LoadFromCache<T> _loadFromStreamedCache;
  StreamSubscription<T> _loadingFromCache;

  void dispose() {
    _parent.dispose();
    _loadingFromCache.cancel();
    _controller.close();
  }

  Future<void> fetch({bool force = false}) async {
    if (force ||
        !_controller.hasValue && _actuallyLoadFromSyncCache() != null) {
      await _parent.fetch();
    }
  }

  bool _actuallyLoadFromSyncCache() {
    final value = _loadFromSyncCache();
    if (value != null) {
      _controller.add(value);
      return true;
    }
    return false;
  }

  @override
  StreamSubscription<T> listen(
    void Function(T event) onData, {
    Function onError,
    void Function() onDone,
    bool cancelOnError,
  }) {
    return _controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  bool get isBroadcast => true;
}

extension AsCachedFetched<T> on Stream<T> {
  _ConvertedHiveCachedFetchStream<T> _asHiveCached(
          Future<void> Function({bool force}) rawFetcher,
          VoidCallback disposer) =>
      _ConvertedHiveCachedFetchStream(this, rawFetcher, disposer);
}

class _ConvertedHiveCachedFetchStream<T> extends HiveCachedFetchStream<T> {
  _ConvertedHiveCachedFetchStream(
      this._parent, this._rawFetcher, this._disposer)
      : super._();

  HiveCachedFetchStream<T> _parent;
  Future<void> Function({bool force}) _rawFetcher;
  VoidCallback _disposer;

  @override
  Future<void> fetch({bool force = false}) => _rawFetcher(force: force);

  @override
  void dispose() => _disposer();

  @override
  StreamSubscription<T> listen(void Function(T event) onData,
          {Function onError, void Function() onDone, bool cancelOnError}) =>
      _parent.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);

  @override
  Future<bool> any(bool Function(T element) test) => _parent.any(test);

  @override
  HiveCachedFetchStream<T> asBroadcastStream(
          {void Function(StreamSubscription<T> subscription) onListen,
          void Function(StreamSubscription<T> subscription) onCancel}) =>
      _parent.asBroadcastStream()._asHiveCached(_rawFetcher, _disposer);

  @override
  HiveCachedFetchStream<E> asyncExpand<E>(
          Stream<E> Function(T event) convert) =>
      _parent.asyncExpand(convert)._asHiveCached(_rawFetcher, _disposer);

  @override
  HiveCachedFetchStream<E> asyncMap<E>(FutureOr<E> Function(T event) convert) =>
      _parent.asyncMap(convert)._asHiveCached(_rawFetcher, _disposer);

  @override
  HiveCachedFetchStream<R> cast<R>() =>
      _parent.cast<R>()._asHiveCached(_rawFetcher, _disposer);

  @override
  Future<bool> contains(Object needle) => _parent.contains(needle);

  @override
  HiveCachedFetchStream<T> distinct(
          [bool Function(T previous, T next) equals]) =>
      _parent.distinct(equals)._asHiveCached(_rawFetcher, _disposer);

  @override
  Future<E> drain<E>([E futureValue]) => _parent.drain<E>(futureValue);

  @override
  Future<T> elementAt(int index) => _parent.elementAt(index);

  @override
  Future<bool> every(bool Function(T element) test) => _parent.every(test);

  @override
  HiveCachedFetchStream<S> expand<S>(Iterable<S> Function(T element) convert) =>
      _parent.expand(convert)._asHiveCached(_rawFetcher, _disposer);

  @override
  Future<T> get first => _parent.first;

  @override
  Future<T> firstWhere(bool Function(T element) test, {T Function() orElse}) =>
      _parent.firstWhere(test, orElse: orElse);

  @override
  Future<S> fold<S>(
          S initialValue, S Function(S previous, T element) combine) =>
      _parent.fold(initialValue, combine);

  @override
  Future forEach(void Function(T element) action) => _parent.forEach(action);

  @override
  HiveCachedFetchStream<T> handleError(Function onError,
          {bool Function(dynamic error) test}) =>
      _parent
          .handleError(onError, test: test)
          ._asHiveCached(_rawFetcher, _disposer);

  @override
  bool get isBroadcast => _parent.isBroadcast;

  @override
  Future<bool> get isEmpty => _parent.isEmpty;

  @override
  Future<String> join([String separator = ""]) => _parent.join(separator);

  @override
  Future<T> get last => _parent.last;

  @override
  Future<T> lastWhere(bool Function(T element) test, {T Function() orElse}) =>
      _parent.lastWhere(test, orElse: orElse);

  @override
  Future<int> get length => _parent.length;

  @override
  HiveCachedFetchStream<S> map<S>(S Function(T event) convert) =>
      _parent.map(convert)._asHiveCached(_rawFetcher, _disposer);

  @override
  Future pipe(StreamConsumer<T> streamConsumer) => _parent.pipe(streamConsumer);

  @override
  Future<T> reduce(T Function(T previous, T element) combine) =>
      _parent.reduce(combine);

  @override
  Future<T> get single => _parent.single;

  @override
  Future<T> singleWhere(bool Function(T element) test, {T Function() orElse}) =>
      _parent.singleWhere(test, orElse: orElse);

  @override
  HiveCachedFetchStream<T> skip(int count) =>
      _parent.skip(count)._asHiveCached(_rawFetcher, _disposer);

  @override
  HiveCachedFetchStream<T> skipWhile(bool Function(T element) test) =>
      _parent.skipWhile(test)._asHiveCached(_rawFetcher, _disposer);

  @override
  HiveCachedFetchStream<T> take(int count) =>
      _parent.take(count)._asHiveCached(_rawFetcher, _disposer);

  @override
  HiveCachedFetchStream<T> takeWhile(bool Function(T element) test) =>
      _parent.takeWhile(test)._asHiveCached(_rawFetcher, _disposer);

  @override
  HiveCachedFetchStream<T> timeout(Duration timeLimit,
          {void Function(EventSink<T> sink) onTimeout}) =>
      _parent.timeout(timeLimit)._asHiveCached(_rawFetcher, _disposer);

  @override
  Future<List<T>> toList() => _parent.toList();

  @override
  Future<Set<T>> toSet() => _parent.toSet();

  @override
  HiveCachedFetchStream<S> transform<S>(
          StreamTransformer<T, S> streamTransformer) =>
      _parent
          .transform(streamTransformer)
          ._asHiveCached(_rawFetcher, _disposer);

  @override
  HiveCachedFetchStream<T> where(bool Function(T event) test) =>
      _parent.where(test)._asHiveCached(_rawFetcher, _disposer);
}
