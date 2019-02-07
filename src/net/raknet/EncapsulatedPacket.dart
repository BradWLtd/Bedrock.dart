import '../../utils/BinaryStream.dart';
import '../../utils/BitFlag.dart';
import '../../utils/Logger.dart';
import '../Packet.dart';
import 'Protocol.dart';
import '../Reliability.dart';

class EncapsulatedPacket extends Packet {

  int flags = Protocol.DataPacketFour;

  int reliability = 0;
  int length = 0;
  int messageIndex = 0;

  bool hasSplit = false;
  int splitCount = 0;
  int splitId = 0;
  int splitIndex = 0;
  
  int sequenceIndex = 0;
  
  int orderIndex = 0;
  int orderChannel = 0;

  bool needsACK = false;

  EncapsulatedPacket([ int id = 0 ]) : super(id);

  BinaryStream encode() {
    BinaryStream stream = new BinaryStream(1024);

    int flags = this.reliability << 5;
    if(this.hasSplit) flags = flags |= BitFlag.HasSplit;

    BinaryStream packetStream = super.encode();

    stream.writeByte(flags);
    stream.writeShort(packetStream.length << 3);

    if(this.isReliable()) stream.writeLTriad(this.messageIndex);

    if(this.isSequenced()) stream.writeLTriad(this.sequenceIndex);

    if(this.isSequencedOrOrdered()) {
      stream.writeLTriad(this.orderIndex);
      stream.writeByte(this.orderChannel);
    }

    if(this.hasSplit) {
      stream.writeInt(this.splitCount);
      stream.writeShort(this.splitId);
      stream.writeInt(this.splitIndex);
    }

    stream.append(packetStream);

    return stream;
  }

  static EncapsulatedPacket from(BinaryStream stream) {
    EncapsulatedPacket packet = new EncapsulatedPacket();
    packet.flags = stream.readByte();

    packet.reliability = ((packet.flags & 0xe0) >> 5);
    packet.hasSplit = (packet.flags & BitFlag.HasSplit) > 0;

    packet.length = (stream.readShort() / 8).ceil();

    if(packet.isReliable()) {
      packet.messageIndex = stream.readLTriad();
    }

    if(packet.isSequenced()) {
      packet.sequenceIndex = stream.readLTriad();
    }

    if(packet.isSequencedOrOrdered()) {
      packet.orderIndex = stream.readLTriad();
      packet.orderChannel = stream.readByte();
    }

    if(packet.hasSplit) {
      packet.splitCount = stream.readInt();
      packet.splitId = stream.readShort();
      packet.splitIndex = stream.readInt();
    }

    print('packet length: ${packet.length}, stream offset: ${stream.offset}, stream length: ${stream.length}');
    packet.setStream(packet.length > (stream.length - stream.offset) ? new BinaryStream() : stream.read(packet.length)); 

    if(packet.getStream().length > 0) {
      packet.setId(packet.getStream().readByte());
      packet.getStream().offset = 0;
    }
    
    return packet;
  }

  bool isReliable() {
    return (
      this.reliability == Reliability.Reliable ||
      this.reliability == Reliability.ReliableOrdered ||
      this.reliability == Reliability.ReliableSequenced ||
      this.reliability == Reliability.ReliableACK ||
      this.reliability == Reliability.ReliableOrderedACK
    );
  }

  bool isSequenced() {
    return (
      this.reliability == Reliability.UnreliableSequenced ||
      this.reliability == Reliability.ReliableSequenced
    );
  }

  bool isOrdered() {
    return (
      this.reliability == Reliability.ReliableOrdered ||
      this.reliability == Reliability.ReliableOrderedACK
    );
  }

  bool isSequencedOrOrdered() {
    return this.isSequenced() || this.isOrdered();
  }

}