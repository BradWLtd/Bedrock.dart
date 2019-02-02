import '../utils/BinaryStream.dart';

abstract class Packet {
  int _id;

  BinaryStream _stream;

  int _streamLength;

  Packet(int id, [ int this._streamLength = 256 ]) {
    this._id = id;
  }

  int getId() {
    return this._id;
  }

  void setId(int val) {
    this._id = val;
  }

  BinaryStream getStream() {
    return this._stream;
  }

  Packet setStream(BinaryStream stream) {
    this._stream = stream;

    return this;
  }

  Packet decode(BinaryStream stream) {
    this.setStream(stream);

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
    this.setStream(new BinaryStream(this._streamLength));
    this.encodeHeader();
    this.encodeBody();
    int offset = this.getStream().offset;
    this.getStream().offset = 0;
    return this.getStream().read(offset);
  }

  void encodeHeader() {
    this.getStream().writeByte(this.getId());
  }

  void encodeBody() {

  }
}