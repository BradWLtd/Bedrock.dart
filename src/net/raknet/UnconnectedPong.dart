import '../Packet.dart';
import 'Protocol.dart';
import '../../Server.dart';

class UnconnectedPong extends Packet {

  int pingId;
  String motd;
  int playerCount;
  int maxPlayers;
  String secondaryName = Server.SYSTEM_NAME;

  UnconnectedPong() : super(Protocol.UnconnectedPong);

  void encodeBody() {
    String name = 'MCPE;${this.motd};27;${Protocol.BedrockVersion};${this.playerCount};${this.maxPlayers};0;${this.secondaryName}';

    this.getStream().writeLong(this.pingId);
    this.getStream().writeLong(Protocol.ServerId);
    this.getStream().writeMagic();
    this.getStream().writeShort(name.length);
    this.getStream().writeString(name);
    this.getStream().writeBoolean(true);
  }
}
