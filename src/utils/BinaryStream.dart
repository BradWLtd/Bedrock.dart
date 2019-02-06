import 'dart:typed_data';
import 'package:typed_data/typed_buffers.dart';

import 'Address.dart';
import '../net/raknet/Protocol.dart';

class BinaryStream {

  /*
   * 
   * https://gitlab.com/mark-nordine/byte_array
   * 
   */

  ByteData _byteData;
  Endian endian;
  int _offset = 0;

  BinaryStream([int length = 0, endian = Endian.big])
  {
    this.endian = endian;
    final buff = Uint8Buffer(length);
    _byteData = ByteData.view(buff.buffer);
  }

  BinaryStream.fromByteData(this._byteData, [this.endian = Endian.little]);

  factory BinaryStream.fromBuffer(ByteBuffer buffer,
      [int offset = 0, int length = null, Endian endian = Endian.little])
  {
    length ??= buffer.lengthInBytes - offset;

    final view = ByteData.view(buffer, offset, length);
    return BinaryStream.fromByteData(view, endian);
  }

  static BinaryStream fromString(String str) {
    List<int> chars = str.codeUnits;
    BinaryStream stream = BinaryStream(chars.length);

    stream.writeBytesList(chars);
    stream.offset = 0;

    return stream;
  }

  int readSignedByte() => _getNum<int>((i, _) => _byteData.getInt8(i), 1);
  int readByte() => _getNum<int>((i, _) => _byteData.getUint8(i), 1);

  /// Returns true if not equal to zero
  bool readBoolean() => readByte() != 0;

  int readSignedShort() => _getNum<int>(_byteData.getInt16, 2);
  int readShort() => _getNum<int>(_byteData.getUint16, 2);

  int readInt() => _getNum<int>(_byteData.getInt32, 4);
  int readUnsignedInt() => _getNum<int>(_byteData.getUint32, 4);

  int readSignedLong() => _getNum<int>(_byteData.getInt64, 8);
  int readLong() => _getNum<int>(_byteData.getUint64, 8);

  double readFloat() => _getNum<double>(_byteData.getFloat32, 4);
  double readDouble() => _getNum<double>(_byteData.getFloat64, 8);

  void writeSigendByte(int value) => _setNum<int>((i, v, _) => _byteData.setInt8(i, v), value, 1);
  void writeByte(int value) => _setNum<int>((i, v, _) => _byteData.setUint8(i, v), value, 1);

  /// Writes [int], 1 if true, zero if false
  void writeBoolean(bool value) => writeByte(value ? 1 : 0);

  void writeShort(int value) => _setNum(_byteData.setInt16, value, 2);
  void writeUnsignedShort(int value) => _setNum(_byteData.setUint16, value, 2);

  void writeInt(int value) => _setNum(_byteData.setInt32, value, 4);
  void writeUnsignedInt(int value) => _setNum(_byteData.setUint32, value, 4);

  void writeLong(int value) => _setNum(_byteData.setInt64, value, 8);
  void writeUnsignedLong(int value) => _setNum(_byteData.setUint64, value, 8);

  void writeFloat(double value) => _setNum(_byteData.setFloat32, value, 4);
  void writeDouble(double value) => _setNum(_byteData.setFloat64, value, 8);

  /// Get byte at given index
  int operator [] (int i) => _byteData.getInt8(i);

  /// Set byte at given index
  void operator []= (int i, int value) => _byteData.setInt8(i, value);

  /// Appends [other] to [this]
  BinaryStream operator + (BinaryStream other) =>
    BinaryStream(length + other.length)
      ..writeBytes(this)
      ..writeBytes(other);

  Iterable<int> byteStream() sync*
  {
    while (offset < length) yield this[offset++];
  }

  /// Returns true if every byte in both [BinaryStream]s are equal
  /// Note: offsets will not be affected
  @override
  bool operator == (Object otherObject)
  {
    if (otherObject is! BinaryStream) return false;

    final BinaryStream other = otherObject;

    if (length != other.length) return false;

    for (var i = 0; i < length; i++) if (this[i] != other[i]) return false;

    return true;
  }

  @override
  int get hashCode
  {
    final tempOffset = offset;

    const p = 16777619;
    var hash = 2166136261;

    for (var i = 0; i < length; i++)
      hash = (hash ^ this[i]) * p;

    offset = tempOffset;

    hash += hash << 13;
    hash ^= hash >> 7;
    hash += hash << 3;
    hash ^= hash >> 17;
    hash += hash << 5;
    return hash;
  }

  /// Copies bytes from [bytes] to [this]
  void writeBytes(BinaryStream bytes, [int offset = 0, int byteCount = 0])
  {
    if (byteCount == 0) byteCount = bytes.length;

    // Copy old offset so we can reset it after copy
    final oldOffset = bytes.offset;
    bytes.offset = offset;

    for (var i = 0; i < byteCount; i++)
      writeByte(bytes.readByte());

    bytes.offset = oldOffset;
  }

  void _setNum<T extends num>(void Function(int, T, Endian) f, T value, int size)
  {
    if (_offset + size > length)
      throw RangeError('attempted to write to offset ${_offset + size}, length is $length');

    f(offset, value, endian);
    _offset += size;
  }

  T _getNum<T extends num>(T Function(int, Endian) f, int size)
  {
    if (_offset + size > length)
      throw RangeError('attempted to read from offset ${_offset + size}, length is $length');

    final data = f(_offset, endian);
    _offset += size;
    return data;
  }

  int get length => _byteData.lengthInBytes;

  ByteBuffer get buffer => _byteData.buffer;

  int get bytesAvailable => length - _offset;

  int get offset => _offset;
  set offset(int value)
  {
    if (value < 0 || value > length)
      throw RangeError('attempting to set offset to $value, length is $length');

    _offset = value;
  }

  /*
   *
   * Bedrock.dart Custom Methods
   * 
   */

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
    BinaryStream stream = this.read(this.readUnsignedVarInt());
    List<int> chars = stream.buffer.asUint8List();
    return String.fromCharCodes(chars);
  }

  void writeMagic() {
    this.writeBytesList(Protocol.Magic);
  }

  void writeString(String val) {
    this.writeBytesList(val.codeUnits);
  }

  void append(BinaryStream arr) {    
    this.writeBytesList(new Uint8List.view(arr.buffer));
  }

  int readLTriad() {
    int one = this.readByte();
    int two = this.readByte();
    int three = this.readByte();
    
    return one + two * 2 ^ 8 + three * 2 ^ 16;
  }

  void writeLTriad(int val) {
    this.writeByte(val);
    val = (val & 0xffff) >> 2;
    this.writeByte(val);
    val = (val & 0xffff) >> 2;
    this.writeByte(val);
  }

  int get writtenLength {
    return this.offset;
  }

  bool feof() {
    return this.offset >= this.length;
  }

  int readLShort() {
    this.endian = Endian.little;
    int val = this.readShort();
    this.endian = Endian.big;
    return val;
  }

  Address readAddress() {
    Address addr = new Address('', 0, AddressFamily.V4);
    
    int family = this.readByte();
    switch(family) {
      case 4:
        List<int> ipParts = [];
        for(int i = 0; i < 4; i++) {
          ipParts.add(~this.readByte() & 0xff);
        }
        addr.ip = ipParts.join('.');
        addr.port = this.readShort();
        break;
      case 6:
        // TODO: Actually implement
        this.read(26);
        this.readShort();
        break;
      default:
        throw new Exception('Unsupported address family: ${family}');
    }
    return addr;
  }

  void writeAddress(Address address) {
    switch(address.family) {
      case AddressFamily.V4:
        this.writeByte(4);
        address.ip.split('.').forEach((b) => this.writeByte(~int.parse(b) & 0xff));
        this.writeShort(address.port);
        break;
      default:
        throw new Exception('Unsupported address family: ${address.family}');
    }
  }

  void writeBytesList(List<int> bytes) {
    for(final int byte in bytes) {
      this.writeByte(byte);
    }
  }

  BinaryStream slice(int length, [ int offset ]) {
    final bytes = new Uint8List.view(this.buffer, offset ?? this.offset, length);
    BinaryStream stream = new BinaryStream(length);
    stream.writeBytesList(bytes);

    return stream;
  }

}