library hive_cache;

import 'dart:collection';

import 'package:hive/hive.dart';

class HiveCache {
  static const _cacheRootId = '_cache_root_';

  final String name;
  final int maxEntries;
  final bool isLazy;

  Box _children;
  LazyBox _data;
  Future<void> _initializer;
  bool get isInitialized => _children != null && _data != null;

  HiveCache({
    this.name = 'cache',
    this.maxEntries,
    this.isLazy,
  }) : assert(name != null) {
    _initializer = () async {
      // Open the boxes.
      await Future.wait([
        () async {
          _children = await Hive.openBox('_children_$name');
        }(),
        () async {
          _data = await Hive.openBox(name);
        }(),
      ]);
      await _collectGarbage();
    }();
  }

  Future<void> _ensureInitialized() async {
    if (!isInitialized) await _initializer;
    assert(isInitialized);
  }

  Future<void> _collectGarbage() async {
    await _ensureInitialized();

    // Go through the children relation and check all ids that are useful
    // (that is the '_cache_root_' and all its recursive children).
    final usefulIds = <String>{_cacheRootId};
    final queue = Queue<String>()..add(_cacheRootId);

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

  Future<void> setEntry(String key, dynamic value) async {
    await _ensureInitialized();
    await _data.put(key, value);
  }

  Future<dynamic> getEntry(String key) async {
    await _ensureInitialized();
    return await _data.get(key);
  }

  Future<void> setChildren(String key, List<String> children) async {
    await _ensureInitialized();
    await _children.put(key, children);
  }

  Future<List<String>> getChildren(String key) async {
    await _ensureInitialized();
    return (_children.get(key) as List).cast<String>();
  }
}
