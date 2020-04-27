part of 'cache.dart';

/// An object in the business logic, like a [Course] or a [User].
@immutable
abstract class Entity<E extends Entity<E>> {
  const Entity._();

  Id<E> get id;
}

/// An [Id] that identifies an [Entity] among all other [Entity]s, even of
/// different types.
@immutable
class Id<E extends Entity<E>> {
  const Id(this.value) : assert(value != null);

  factory Id.orNull(String value) => value == null ? null : Id<E>(value);

  final String value;

  Type get type => E;
  int get typeId => HiveCache.typeIdByType<E>();

  Id<S> cast<S extends Entity<S>>() => Id<S>(value);

  @override
  bool operator ==(other) => other is Id<E> && other.value == value;
  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
  String toJson() => value;
}

extension StringToId on String {
  Id<E> toId<E extends Entity<E>>() => Id<E>(this);
}

extension StringListToId on List<String> {
  List<Id<E>> toIds<E extends Entity<E>>() => map((id) => Id<E>(id)).toList();
}
