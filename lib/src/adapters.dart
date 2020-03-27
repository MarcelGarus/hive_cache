part of 'cache.dart';

const typeIdForId = 200;
const typeIdForIdCollection = 201;
const typeIdForIdConnection = 202;

class _AdapterForId extends TypeAdapter<Id<dynamic>> {
  @override
  int get typeId => typeIdForId;

  @override
  void write(BinaryWriter writer, Id<dynamic> id) => writer
    ..writeInt(id.typeId)
    ..writeString(id.value);

  @override
  Id<dynamic> read(BinaryReader reader) =>
      HiveCache._createIdOfTypeId(reader.readInt(), reader.readString());
}

class _AdapterForIdCollectionData
    extends TypeAdapter<_CollectionData<dynamic>> {
  @override
  int get typeId => typeIdForIdCollection;

  @override
  void write(BinaryWriter writer, _CollectionData<dynamic> collection) => writer
    ..writeInt(collection.typeId)
    ..writeString(collection.id.value)
    ..writeStringList(collection.childrenIds.map((id) => id.value).toList());

  @override
  _CollectionData<dynamic> read(BinaryReader reader) =>
      HiveCache._createCollectionOfTypeId(
        reader.readInt(),
        reader.readString(),
        reader.readStringList(),
      );
}

class _AdapterForIdConnectionData
    extends TypeAdapter<_ConnectionData<dynamic>> {
  @override
  int get typeId => typeIdForIdConnection;

  @override
  void write(BinaryWriter writer, _ConnectionData<dynamic> connection) => writer
    ..writeInt(connection.typeId)
    ..writeString(connection.id.value)
    ..writeString(connection.connectedId.value);

  @override
  _ConnectionData<dynamic> read(BinaryReader reader) =>
      HiveCache._createConnectionOfTypeId(
        reader.readInt(),
        reader.readString(),
        reader.readString(),
      );
}
