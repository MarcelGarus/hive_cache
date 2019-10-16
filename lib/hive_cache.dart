library hive_cache;

import 'dart:collection';

import 'package:hive/hive.dart';

class HiveCache {
  static const _cacheRootKey = '_cache_root_';

  final String name;

  Box _children;
  LazyBox _data;
  bool get isInitialized => _children != null && _data != null;

  HiveCache({this.name = 'cache'}) : assert(name != null);

  Future<void> initialize() async {
    await Future.wait([
      () async {
        _children = await Hive.openBox('_children_$name');
      }(),
      () async {
        _data = await Hive.openBox(name);
      }(),
    ]);
    await _collectGarbage();
  }

  Future<void> _collectGarbage() async {
    assert(isInitialized);

    // Go through the children relation and check all ids that are useful
    // (that is the '_cache_root_' and all its recursive children).
    final usefulIds = <String>{_cacheRootKey};
    final queue = Queue<String>()..add(_cacheRootKey);

    while (queue.isNotEmpty) {
      final id = queue.removeFirst();
      if (usefulIds.contains(id)) continue;

      usefulIds.add(id);
      final children = _children.get(id) ?? [];
      queue.addAll(children);
    }

    // Remove all the non-useful children relations and data entries.
    final nonUsefulIds = _children.keys.toSet().difference(usefulIds);
    _children.deleteAll(nonUsefulIds);
    _data.deleteAll(nonUsefulIds);
  }

  Future<void> put(String key, dynamic value) async {
    assert(isInitialized);
    await _data.put(key, value);
  }

  Future<dynamic> get(String key) async {
    assert(isInitialized);
    return await _data.get(key);
  }

  Future<void> putChildren(String key, List<String> children) async {
    assert(isInitialized);
    await _children.put(key, children);
  }

  Future<List<String>> getChildren(String key) async {
    assert(isInitialized);
    return (_children.get(key) as List).cast<String>();
  }

  Future<void> putRootChildren(List<String> children) async {
    await putChildren(_cacheRootKey, children);
  }

  Future<List<String>> getRootChildren() async {
    return await getChildren(_cacheRootKey);
  }
}
