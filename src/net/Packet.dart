import '../utils/BinaryStream.dart';

abstract class Packet {

  int _id;

  BinaryStream _stream;

  Packet(int id) {
    this._id = id;
  }

  int getId() {
    return this._id;
  }

  BinaryStream getStream() {
    return this._stream;
  }

  Packet decode(BinaryStream stream) {
    this._stream = stream;

    this.decodeHeader();
    this.decodeBody();

    return this;
  }

  void decodeHeader() {
    this._id = this.getStream().readByte();
  }

  void decodeBody() {

  }

  BinaryStream encode() {
    this._stream = new BinaryStream();
  }
}