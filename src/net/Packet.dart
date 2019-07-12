import '../utils/BinaryStream.dart';

abstract class Packet {
  bool decoded = false;
  bool encoded = false;

  BinaryStream encodedStream;

  int id;

  BinaryStream _stream;

  int _streamLength;

  Packet(this.id, [int this._streamLength = 10240]) {
    this.encodedStream = this.generateStream();
  }

  void setId(int val) {
    this.id = val;
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

    this.decoded = true;

    return this;
  }

  void decodeHeader() {
    this.id = this.getStream().readByte();
  }

  void decodeBody() {}

  BinaryStream encode() {
    this.setStream(this.generateStream());
    this.encodeHeader();
    this.encodeBody();
    int offset = this.getStream().offset;
    this.getStream().offset = 0;
    BinaryStream stream = this.getStream().read(offset);

    this.encoded = true;
    this.encodedStream = stream;

    return stream;
  }

  void encodeHeader() {
    this.getStream().writeByte(this.id);
  }

  void encodeBody() {}

  BinaryStream generateStream() {
    return BinaryStream(this._streamLength);
  }
}
