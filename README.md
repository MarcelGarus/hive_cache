While Hive allows you to save arbitrary objects into memory, you still need to worry about fetching data.
Usually, when fetching data from a server, every item has a unique id.
Data items which have an `Id` called  `Entity`s in this package:

```dart
@HiveType(typeId: 0)
class Fruit implements Entity<Fruit> {
  @HiveField(fieldId: 0)
  final Id<Fruit> id;
  
  @HiveField(fieldId: 1)
  final String name;

  @HiveField(fieldId: 2)
  final int amount;
}
```

Before doing anything, you should initialize the `HiveCache`.
Instead of registering your `TypeAdapter`s at `Hive` yourself, you can just register them at `HiveCache`, which does that for you.
For `Entity`'s, you should call `registerEntityType` instead of `registerAdapter` and provide a method that get executed whenever an `Entity` should be fetched:

```dart
await HiveCache.initialize();
HiveCache
  ..registerAdapter(SomeAdapter())
  ..registerEntityType(FruitAdapter())
  ..registerEntityType(SomeOtherEntityAdapter());
```

Then, if you have an `Id<Fruit>`, you can simply use an `EntityBuilder` to build the `Fruit`:

```dart
final id = Id<Fruit>('some-fruit');

...

EntityBuilder(
  id: Id<Fruit>('some-fruit'),
  builder: (context, snapshot, fetch) {
    if (snapshot == null) {
      // Still loading.
      return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasData) {
      // The snapshot contains data. It may be [null] if the fetch function
      // returned [null].
      return Text(snapshot.data);
    } else if (snapshot.hasError) {
      return Text('${snapshot.error}, ${snapshot.stackTrace}');
    }
  },
),
```

## Live updating

You can call `saveToCache()` on any `Entity` to save it to the cache.
All builders that reference this `Entity` get automatically updated.

You can call `loadFromCache()` on any `Id<T>` to retrieve a `Stream<T>` of the entity.
Whenever a new item gets saved to the cache, the `Stream` contains a new event with this item.

## Lazy references

You can not only reference other `Entity`s by their `Id` or multiple `Entity`s by a `List<Id>`, but you can also have lazy fetching of other entities:

```dart
@HiveType(typeId: 1)
class Person implements Entity<Person> {
  @HiveField(fieldId: 0)
  final Id<Person> id;
  
  @HiveField(fieldId: 1)
  final String name;

  // Lazy reference to an entity.
  @HiveField(fieldId: 2)
  final Connection<Person> mom;

  // Lazy reference to multiple entities.
  @HiveField(fieldId: 3)
  final Collection<Person> friends;
}
```

You can use `ConnectionBuilder`s or `CollectionBuilder`s to build these `Entity`s similarly to how you would use an `EntityBuilder`.
In the builder, you get the `Id` or `List<Id>` that the item references.
If you want to get the actual `Entity` or `List<Entity>`, you can use the `ConnectionBuilder.populated` and `CollectionBuilder.populated` constructors.
