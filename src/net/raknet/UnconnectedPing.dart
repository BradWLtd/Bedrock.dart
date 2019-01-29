import '../Packet.dart';
import 'Protocol.dart';

class UnconnectedPing extends Packet {

  int pingId;

  UnconnectedPing() : super(Protocol.UnconnectedPing);

  void decodeBody() {
    this.pingId = this.getStream().readLong();
  }
}
