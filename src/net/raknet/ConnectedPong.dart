import 'EncapsulatedPacket.dart';
import 'Protocol.dart';

class ConnectedPong extends EncapsulatedPacket {

  int sendPingTime;
  int sendPongTime;

  ConnectedPong() : super(Protocol.ConnectedPong);

  void encodeBody() {
    this.getStream().writeLong(this.sendPingTime);
    this.getStream().writeLong(this.sendPongTime);
  }

  void decodeBody() {
    this.sendPingTime = this.getStream().readLong();
    this.sendPongTime = this.getStream().readLong();
  }
}
