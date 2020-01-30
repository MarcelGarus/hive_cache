import 'package:hive/hive.dart';
import 'package:hive_cache/hive_cache.dart';
import 'package:meta/meta.dart';

class Person extends Entity<Person> {
  const Person({
    @required this.id,
    @required this.firstName,
    @required this.lastName,
    @required this.friends,
  });

  final Id<Person> id;
  final String firstName;
  final String lastName;
  final List<Id<Person>> friends;

  String toString() => '$firstName $lastName';
}

class PersonAdapter extends TypeAdapter<Person> {
  @override
  final typeId = 51;

  @override
  Person read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Person(
      id: fields[0] as Id,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      friends: (fields[3] as List).cast<Id<Person>>(),
    );
  }

  @override
  void write(BinaryWriter writer, Person obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.friends);
  }
}

void main() async {
  Hive.init('.');
  Hive.registerAdapter(PersonAdapter(), 51);
  HiveCache.initialize({
    CacheBox<Person>(
      typeId: 0,
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
