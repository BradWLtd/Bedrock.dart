import '../Packet.dart';
import 'Protocol.dart';

class IncompatibleProtocol extends Packet {

  IncompatibleProtocol() : super(Protocol.IncompatibleProtocol);

  void encodebody() {
    this.getStream().writeByte(Protocol.ProtocolVersion);
    this.getStream().writeMagic();
    this.getStream().writeLong(Protocol.ServerId);
  }

}