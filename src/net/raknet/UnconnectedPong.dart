import '../Packet.dart';
import 'Protocol.dart';

class UnconnectedPong extends Packet {

  int pingId;
  String name;
  int maxPlayers;
  String secondaryName;

  UnconnectedPong() : super(Protocol.UnconnectedPong);

  void encodeBody() {
    const name = `MCPE;${this.name};27;1.8.0;0;${this.maxPlayers};0;${this.secondaryName}`

    return this.getStream()
      .writeLong(this.pingId)
      .writeLong(Protocol.SERVER_ID)
      .writeMagic()
      .writeShort(name.length)
      .writeString(name)
  }
}
