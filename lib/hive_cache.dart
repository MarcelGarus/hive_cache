library hive_cache;

import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

class Id<T extends Entity<T>> {
  Id(this.id) {
    _box = HiveCache._boxForType<T>(T);
  }

  final String id;
  CacheBox<T> _box;

  T get value => _box.box.get(id);
  Type get type => T;
}

class AdapterForId extends TypeAdapter<Id<dynamic>> {
  @override
  void write(BinaryWriter writer, Id<dynamic> id) {
    final type = id.type;
    final typeId = HiveCache._untypedBoxForType(type).typeId;
    writer
      ..writeInt(typeId)
      ..writeString(id.id);
  }

  @override
  Id read(BinaryReader reader) {
    final typeId = reader.readInt();
    final box = HiveCache._boxForTypeId(typeId);
    return box._createId(reader.readString());
  }
}

abstract class Entity<T extends Entity<T>> {
  const Entity();

  Id<T> get id;
}

class CacheBox<T extends Entity<T>> {
  CacheBox({@required this.typeId, @required this.box});

  final int typeId;
  final Box box;

  Type get type => T;

  Id<T> _createId(String id) => Id<T>(id);
}

class HiveCacheImpl {
  final _boxes = <Type, CacheBox<dynamic>>{};

  CacheBox<dynamic> _untypedBoxForType(Type type) {
    final box = _boxes[type];
    if (box == null) {
      throw Exception('Unknown type $type. Did you forget to register a box?');
    }
    return box;
  }

  CacheBox<T> _boxForType<T extends Entity<T>>(Type type) {
    return _untypedBoxForType(type) as CacheBox<T>;
  }

  CacheBox<dynamic> _boxForTypeId(int typeId) {
    return _boxes.values.singleWhere((box) => box.typeId == typeId);
  }

  void initialize(Iterable<CacheBox> boxes) {
    Hive.registerAdapter(AdapterForId(), 223);

    for (final box in boxes) {
      _boxes[box.type] = box;
    }
  }

  void put<T extends Entity<T>>(T entity) {
    final box = _boxForType<T>(entity.runtimeType);
    box.box.put(entity.id.id, entity);
  }

  T get<T extends Entity<T>>(Id<T> id) {
    final box = _boxForType<T>(T);
    return box.box.get(id.id) as T;
  }
}

final HiveCache = HiveCacheImpl();

/*class HiveCache {
  final String name;

  Box _rootKeys;
  Box _parents;
  LazyBox _data;
  bool get isInitialized => _parents != null && _data != null;

  HiveCache({this.name = 'cache'}) : assert(name != null);

  Future<void> initialize() async {
    await Future.wait([
      () async {
        _rootKeys = await Hive.openBox('_root_ids_${name}_');
      }(),
      () async {
        _parents = await Hive.openBox('_parents_${name}_');
      }(),
      () async {
        _data = await Hive.openBox(name, lazy: true);
      }(),
    ]);
    await _collectGarbage();
    assert(isInitialized);
  }

  Future<void> _collectGarbage() async {
    assert(isInitialized);

    final children = <String, List<String>>{};
    for (var child in _data.keys) {
      var parent = _parents.get(child);
      children.putIfAbsent(parent, () => []).add(child);
    }

    final usefulIds = <String>{};
    final queue = Queue<String>()..addAll(_rootKeys.values.cast<String>());

    while (queue.isNotEmpty) {
      final id = queue.removeFirst();
      if (usefulIds.contains(id)) continue;

      usefulIds.add(id);
      queue.addAll(children[id] ?? []);
    }

    // Remove all the non-useful children relations and data entries.
    final nonUsefulIds = _data.keys.toSet().difference(usefulIds);
    _parents.deleteAll(nonUsefulIds);
    _data.deleteAll(nonUsefulIds);
  }

  Future<void> put(String key, String parent, dynamic value) async {
    assert(isInitialized);
    await Future.wait([
      _data.put(key, value),
      _parents.put(key, parent),
    ]);
  }

  Future<dynamic> get(String key) async {
    assert(isInitialized);
    return await _data.get(key);
  }

  Future<List<T>> getChildrenOfType<T>(String parentKey) async {
    assert(parentKey != null);

    final childrenKeys =
        _parents.keys.where((key) => _parents.get(key) == parentKey);
    return [
      for (final key in childrenKeys) await _data.get(key),
    ].whereType<T>().toList();
  }

  Future<void> setRootKeys(List<String> keys) async {
    assert(isInitialized);
    await _rootKeys.clear();
    await Future.wait([
      for (var key in keys) _rootKeys.add(key),
    ]);
  }

  Future<List<String>> getRootKeys() async {
    assert(isInitialized);
    return await _rootKeys.values;
  }
}*/
