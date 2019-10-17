library hive_cache;

import 'dart:collection';

import 'package:hive/hive.dart';

class HiveCache {
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
        _data = await Hive.openBox(name);
      }(),
    ]);
    await _collectGarbage();
  }

  Future<void> _collectGarbage() async {
    assert(isInitialized);

    final children = <String, List<String>>{};
    for (var child in _data.keys) {
      var parent = _parents.get(child);
      children.putIfAbsent(parent, () => []).add(child);
    }

    final usefulIds = <String>{};
    final queue = Queue<String>()..addAll(_rootKeys.values);

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
    await _data.put(key, value);
    await _parents.put(key, parent);
  }

  Future<dynamic> get(String key) async {
    assert(isInitialized);
    return await _data.get(key);
  }

  Future<void> setRootKeys(List<String> keys) async {
    _rootKeys.clear();
    await Future.wait([
      for (var key in keys) _rootKeys.add(key),
    ]);
  }

  Future<List<String>> getRootKeys() async {
    return await _rootKeys.values;
  }
}
