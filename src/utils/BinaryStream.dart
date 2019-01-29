import 'dart:typed_data';
import 'package:byte_array/byte_array.dart';

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

  read(int len) {
    BinaryStream value = new BinaryStream(len);

    for(int i = 0; i < len; i++) {
      value.writeByte(this.readByte());
    }

    value.offset = 0;
    return value;
  }

  readUnsignedVarInt() {
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
  
  readString() {
    return this.read(this.readUnsignedVarInt());
  }

}