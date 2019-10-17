## [0.1.0] - 2019-10-17

* `HiveCache` now works the other way around - items depend on their parents.
  So now, there are `put(key, parent, value)`, `get(key)`, `setRootKeys(keys)`
  and `getRootKeys()`.

## [0.0.1] - 2019-10-16

* `HiveCache` supports `put(key, value)`, `get(key)`,
  `putChildren(key, children)`, `getChildren(key)`,
  `putRootChildren(children)` and `getRootChildren()`.
