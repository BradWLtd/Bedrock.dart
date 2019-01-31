import '../Packet.dart';
import 'Protocol.dart';

class OpenConnectionReplyTwo extends Packet {

  int port;
  int mtuSize;

  OpenConnectionReplyTwo() : super(Protocol.OpenConnectionReplyTwo);

  void encodeBody() {
    this.getStream().writeMagic();
    this.getStream().writeLong(Protocol.ServerId);
    this.getStream().writeShort(this.port);
    this.getStream().writeShort(this.mtuSize);
    this.getStream().writeByte(0);
  }

}