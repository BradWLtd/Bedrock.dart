import '../Packet.dart';
import 'Protocol.dart';

class OpenConnectionReplyOne extends Packet {

  int mtuSize;

  OpenConnectionReplyOne() : super(Protocol.OpenConnectionReplyOne);

  void encodeBody() {
    this.getStream().writeMagic();
    this.getStream().writeLong(Protocol.ServerId);
    this.getStream().writeByte(0);
    this.getStream().writeShort(this.mtuSize);
  }

}