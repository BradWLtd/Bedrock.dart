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

  EncapsulatedPacket() : super(0);

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

  EncapsulatedPacket decode(BinaryStream stream) {
    this.flags = stream.readByte();

    this.reliability = ((this.flags & 0xe0) >> 5);
    this.hasSplit = (this.flags & BitFlag.HasSplit) > 0;

    this.length = (stream.readShort() / 8).ceil();

    if(this.isReliable()) {
      this.messageIndex = stream.readLTriad();
    }

    if(this.isSequenced()) {
      this.sequenceIndex = stream.readLTriad();
    }

    if(this.isSequencedOrOrdered()) {
      this.orderIndex = stream.readLTriad();
      this.orderChannel = stream.readByte();
    }

    if(this.hasSplit) {
      this.splitCount = stream.readInt();
      this.splitId = stream.readShort();
      this.splitIndex = stream.readInt();
    }

    this.setId(stream.readByte());

    this.setStream(stream);
    stream.offset += (this.length - 1);

    return this;
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