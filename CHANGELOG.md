## [2.0.2] - 2020-08-22

* Actually update <kbd>rxdart</kbd> dependency.

## [2.0.1] - 2020-08-22

* Update <kbd>rxdart</kbd> dependency.

## [2.0.0] - 2020-04-27

* Complete rewrite of the API.

## [1.0.0] - 2020-01-30

* Complete overhaul of the concept and the API.

## [0.1.3] - 2019-10-26

* Fix minor issues.

## [0.1.2] - 2019-10-26

* Fix minor issues.

## [0.1.1] - 2019-10-26

* Add `getChildrenOfType` method.

## [0.1.0] - 2019-10-17

* `HiveCache` now works the other way around - items depend on their parents.
  So now, there are `put(key, parent, value)`, `get(key)`, `setRootKeys(keys)`
  and `getRootKeys()`.

## [0.0.1] - 2019-10-16

* `HiveCache` supports `put(key, value)`, `get(key)`,
  `putChildren(key, children)`, `getChildren(key)`,
  `putRootChildren(children)` and `getRootChildren()`.
