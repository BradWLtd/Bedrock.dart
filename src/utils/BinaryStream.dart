import 'dart:typed_data';
import 'package:byte_array/byte_array.dart';

import 'Address.dart';
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
    this.writeBytesList(Protocol.Magic);
  }

  void writeString(String val) {
    this.writeBytesList(val.codeUnits);
  }

  void append(ByteArray arr) {    
    this.writeBytesList(new Uint8List.view(arr.buffer));
  }

  int readLTriad() {
    final bytes = new Uint8List.view(this.buffer, this.offset, 3);
    this.offset += 3;

    return (bytes[0] << 16) | (bytes[1] << 8) | bytes[2];
  }

  void writeLTriad(int val) {
    this.writeByte(val & 0xff);
    this.writeByte((val >> 8) & 0xff);
    this.writeByte((val >> 16) & 0xff);
  }

  bool feof() {
    return this.offset >= this.length;
  }

  void writeBytesList(List<int> bytes) {
    for(final int byte in bytes) {
      this.writeByte(byte);
    }
  }

  BinaryStream slice(int length, [ int offset ]) {
    print([ length, offset ?? this.offset ]);
    final bytes = new Uint8List.view(this.buffer, offset ?? this.offset, length);
    print(bytes.length);
    BinaryStream stream = new BinaryStream(length);
    stream.writeBytesList(bytes);

    return stream;
  }

}