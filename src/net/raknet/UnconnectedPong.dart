import '../Packet.dart';
import 'Protocol.dart';

class UnconnectedPong extends Packet {

  int pingId;
  String name;
  int maxPlayers;
  String secondaryName;

  UnconnectedPong() : super(Protocol.UnconnectedPong);

  void encodeBody() {
    String name = 'MCPE;${this.name};27;1.8.0;0;${this.maxPlayers};0;${this.secondaryName}';

    this.getStream().writeLong(this.pingId);
    this.getStream().writeLong(Protocol.ServerId);
    this.getStream().writeMagic();
    this.getStream().writeShort(name.length);
    this.getStream().writeString(name);
    this.getStream().writeBoolean(true);
  }
}
