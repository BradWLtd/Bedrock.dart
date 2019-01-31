import '../Packet.dart';
import 'Protocol.dart';

class OpenConnectionRequestTwo extends Packet {

  int port;
  int mtuSize;
  int clientId;

  OpenConnectionRequestTwo() : super(Protocol.OpenConnectionRequestTwo);

  void decodeBody() {
    this.getStream().offset = 22; // Magic & Security
    this.port = this.getStream().readShort();
    this.mtuSize = this.getStream().readShort();
    this.clientId = this.getStream().readLong();
  }

}