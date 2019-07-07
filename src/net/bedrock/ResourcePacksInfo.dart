import '../../resource-packs/ResourcePack.dart';
import 'GamePacket.dart';
import 'Protocol.dart';

class ResourcePacksInfo extends GamePacket {
  bool packsMandatory = false;
  bool hasScripts = false;
  List<ResourcePack> behaviourPacks = [];
  List<ResourcePack> resoucePacks = [];

  ResourcePacksInfo() : super(Protocol.ResourcePacksInfo);

  void encodeBody() {
    this.getStream()
      ..writeBoolean(this.packsMandatory)
      ..writeBoolean(this.hasScripts)
      ..writeLShort(this.behaviourPacks.length);

    for (final ResourcePack pack in this.behaviourPacks) {
      this.getStream()
        ..writeString(pack.id)
        ..writeString(pack.version)
        ..writeLLong(pack.size)
        ..writeString('')
        ..writeString('')
        ..writeString('')
        ..writeBoolean(false);
    }

    this.getStream().writeLShort(this.resoucePacks.length);
    for (final ResourcePack pack in this.resoucePacks) {
      this.getStream()
        ..writeString(pack.id)
        ..writeString(pack.version)
        ..writeLLong(pack.size)
        ..writeString('')
        ..writeString('')
        ..writeString('')
        ..writeBoolean(false);
    }
  }
}
