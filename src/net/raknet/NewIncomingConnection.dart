import '../../utils/Address.dart';
import '../Packet.dart';
import 'Protocol.dart';

class NewIncomingConnection extends Packet {

  Address address;
  List<Address> systemAddresses = [];
  int sendPingTime;
  int sendPongTime;

  NewIncomingConnection() : super(Protocol.NewIncomingConnection);

  void decodeBody() {
    this.address = this.getStream().readAddress();

    for(int i = 0; i < Protocol.SystemAddresses; i++) {
      this.systemAddresses.add(this.getStream().readAddress());
    }

    this.sendPingTime = this.getStream().readLong();
    this.sendPongTime = this.getStream().readLong();
  }

}