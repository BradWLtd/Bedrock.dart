import 'dart:typed_data';
import 'package:byte_array/byte_array.dart';

import '../net/raknet/Protocol.dart';

class BinaryStream extends ByteArray {

  BinaryStream([ int length = 0 ]) : super(length, Endian.big);

  static from(List<int> data) {
    BinaryStream value = new BinaryStream(data.length);

    for(final int part in data) {
      value.writeByte(part);
    }

    value.offset = 0;
    return value;
  }

  BinaryStream read(int len) {
    BinaryStream value = new BinaryStream(len);

    for(int i = 0; i < len; i++) {
      value.writeByte(this.readByte());
    }

    value.offset = 0;
    return value;
  }

  int readUnsignedVarInt() {
    int value = 0;

    for(int i = 0; i <= 35; i += 7) {
      int b = this.readByte();
      value |= ((b & 0x7f) << i);

      if ((b & 0x80) == 0) {
        return value;
      }
    }

    return 0;
  }
  
  String readString() {
    return this.read(this.readUnsignedVarInt()).toString();
  }

  void writeMagic() {
    for(final int part in Protocol.Magic) {
      this.writeByte(part);
    }
  }

  void writeString(String val) {
    List<int> bytes = val.codeUnits;

    for(final int byte in bytes) {
      this.writeByte(byte);
    }
  }

  void append(ByteArray arr) {
    final bytes = new Uint8List.view(arr.buffer);
    
    for(final int byte in bytes) {
      this.writeByte(byte);
    }
  }

  int readLTriad() {
    this.endian = Endian.little;
    int val = this.readUnsignedInt();
    this.endian = Endian.big;
    return val;
  }

  void writeLTriad(int val) {
    this.endian = Endian.little;
    this.writeUnsignedInt(val);
    this.endian = Endian.big;
  }

}