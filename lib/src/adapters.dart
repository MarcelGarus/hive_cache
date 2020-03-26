part of 'cache.dart';

const typeIdForId = 123;
const typeIdForIdCollection = 124;

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
    extends TypeAdapter<_IdCollectionData<dynamic>> {
  @override
  int get typeId => typeIdForIdCollection;

  @override
  void write(BinaryWriter writer, _IdCollectionData<dynamic> collection) =>
      writer
        ..writeInt(collection.typeId)
        ..writeString(collection.id.value)
        ..writeStringList(
            collection.childrenIds.map((id) => id.value).toList());

  @override
  _IdCollectionData<dynamic> read(BinaryReader reader) =>
      HiveCache._createCollectionOfTypeId(
        reader.readInt(),
        reader.readString(),
        reader.readStringList(),
      );
}
