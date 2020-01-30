While Hive allows you to save arbitrary objects into memory, you still need to worry about multiple boxes and entities referencing each other.
This package is a thin wrapper above Hive that makes it easier to store your entities.

Entities usually relate to one another.
Your entities should implement `Entity` – that means they have to implement an `id` getter, which returns an `Id`, which is just a wrapper of a `String` that uniquely identifies this entity among other entities of the same type.

`Id`s can also be used to reference other entities.
For example, a `Person` might reference another `Person` or even another entity type, like a `Pet`.

```dart

@HiveType(typeId: 0)
class Person extends Entity<Person> {
  const Person({
    @required this.id,
    @required this.firstName,
    @required this.lastName,
    @required this.friends,
  });

  @HiveField(0)
  final Id<Person> id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final List<Id<Person>> friends;

  String toString() => '$firstName $lastName';
}
```

Then, you can create a `HiveCache`. It will manage saving entities among multiple boxes.

```dart
void main() {
  Hive.init('.');
  Hive.registerAdapter(PersonAdapter(), 51);
  HiveCache.initialize({
    CacheBox<Person>(
      typeId: 0, // doesn't have to be the same typeId as for Hive
      box: await Hive.openBox<Person>('people'),
    ),
  });

  final foo = Person(
    id: Id('abc'),
    firstName: 'Foo',
    lastName: 'Blub',
    friends: [Id('abc'), Id('xyz')],
  );
  final bar = Person(
    id: Id('xyz'),
    firstName: 'Bar',
    lastName: 'Plubble',
    friends: [Id('abc')],
  );

  HiveCache.put(foo);
  HiveCache.put(bar);

  final someone = HiveCache.get(Id<Person>('abc'));
  print(someone);
  for (final friendId in someone.friends) {
    print(friendId.value);
  }
}
```

If you create a new class, just make it extend entity, register a `CacheBox` at the `HiveCache` and you're ready to `put` and `get` entities from the `HiveCache`.

For now, the `HiveCache` is persistent.
In the future, it may also support removing unused data (some kind of garbage collection by references or time not used).
