import '../../utils/BinaryStream.dart';
import '../../utils/BitFlag.dart';
import 'EncapsulatedPacket.dart';
import 'Protocol.dart';
import '../Packet.dart';

class Datagram extends Packet {

  List<EncapsulatedPacket> packets = [];

  int flags = 0;
  int sequenceNumber = 0;

  bool packetPair = false;
  bool continuousSend = false;
  bool needsBAndS = false;

  Datagram([ int id = Protocol.DataPacketFour ]) : super(id);

  void encodeHeader() {
    this.getStream().writeByte(BitFlag.Valid | this.flags);
  }

  void encodeBody() {
    this.getStream().writeLTriad(this.sequenceNumber);
    
    for(final EncapsulatedPacket packet in this.packets) {
      this.getStream().append(packet.encode());
    }
  }

  Datagram decode(BinaryStream stream) {
    this.flags = stream.readByte();

    this.packetPair = (this.flags & BitFlag.PacketPair) > 0;
    this.continuousSend = (this.flags & BitFlag.ContinuousSend) > 0;
    this.needsBAndS = (this.flags & BitFlag.NeedsBAndS) > 0;

    this.sequenceNumber = stream.readLTriad();

    while(!stream.feof()) {
      EncapsulatedPacket packet = EncapsulatedPacket.from(stream);

      if(packet.getStream().length < 1) break;

      this.packets.add(packet);
    }

    return this;
  }

  void reset() {
    this.packets = [];
    this.setStream(new BinaryStream());
  }

  int get byteLength {
    int length = 0;
    for(final EncapsulatedPacket pk in this.packets) {
      length += pk.getStream().length;
    }
    return length;
  }

}