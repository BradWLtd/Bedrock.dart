import '../Packet.dart';
import 'Protocol.dart';

class OpenConnectionRequestOne extends Packet {

  int protocol;
  int mtuSize;

  OpenConnectionRequestOne() : super(Protocol.OpenConnectionRequestOne);

  void decodeBody() {
    this.getStream().offset = 17; // Magic
    this.protocol = this.getStream().readByte();
    this.mtuSize = this.getStream().length - 17;
  }

}