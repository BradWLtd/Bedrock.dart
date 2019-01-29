import '../Packet.dart';
import 'Protocol.dart';

class UnconnectedPing extends Packet {

  int pingId;

  UnconnectedPing() : super(Protocol.UnconnectedPing);

  void decodeBody() {
    print(this.getStream().offset);
    this.pingId = this.getStream().readLong();
  }
}
