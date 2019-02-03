import 'EncapsulatedPacket.dart';
import 'Protocol.dart';

class ConnectedPing extends EncapsulatedPacket {

  int sendPingTime;

  ConnectedPing() : super(Protocol.ConnectedPing);

  void encodeBody() {
    this.getStream().writeLong(this.sendPingTime);
  }

  void decodeBody() {
    this.sendPingTime = this.getStream().readLong();
  }
}
