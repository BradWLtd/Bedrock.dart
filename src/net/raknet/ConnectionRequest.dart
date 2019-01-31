import '../Packet.dart';
import 'Protocol.dart';

class ConnectionRequest extends Packet {

  int clientId;
  int sendPingTime;
  bool hasSecurity;

  ConnectionRequest() : super(Protocol.ConnectionRequest);

  void decodeBody() {
    this.clientId = this.getStream().readLong();
    this.sendPingTime = this.getStream().readLong();
    this.hasSecurity = this.getStream().readBoolean();
  }

}