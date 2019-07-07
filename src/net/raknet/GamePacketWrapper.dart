import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../utils/BinaryStream.dart';
import '../../utils/Logger.dart';
import '../bedrock/GamePacket.dart';
import '../bedrock/Login.dart';
import 'EncapsulatedPacket.dart';
import 'Protocol.dart';
import '../bedrock/Protocol.dart' as Bedrock;

class GamePacketWrapper extends EncapsulatedPacket {
  List<GamePacket> packets = [];

  Logger _logger = Logger('GamePacketWrapper');

  GamePacketWrapper() : super(Protocol.GamePacketWrapper);

  void decodeBody() {
    Uint8List bytes =
        this.getStream().readBytes(this.getStream().length - 1, 1);
    List<int> payload = ZLibDecoder().decodeBytes(bytes);
    BinaryStream pStream = BinaryStream.fromBytes(payload);

    while (!pStream.feof()) {
      BinaryStream stream = BinaryStream.fromString(pStream.readString());
      final int packetId = new Uint8List.view(stream.buffer)[0];

      switch (packetId) {
        case Bedrock.Protocol.Login:
          this.packets.add(Login().decode(stream));
          break;
        default:
          this._logger.error(
              'Got unknown GamePacket: ${packetId} (${this._logger.byte(packetId)})');
          this._logger.error(this._logger.bin(stream));
      }
    }
  }

  void encodeBody() {
    BinaryStream payload = BinaryStream(10240); // May be too small?

    for (final GamePacket packet in this.packets) {
      if (packet.encoded) {
        this._logger.error(
            'Found pre-encoded packet whilst encoding, packets should not be encoded.');
      } else {
        BinaryStream stream = packet.encode();

        payload
          ..writeUnsignedVarInt(stream.length)
          ..append(stream);
      }
    }

    Uint8List bytes = payload.readBytes(payload.writtenLength - 1, 1);
    List<int> encoded = ZLibEncoder().encode(bytes);

    this.getStream().append(BinaryStream.fromBytes(encoded));
  }
}
