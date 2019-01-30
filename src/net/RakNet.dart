import '../utils/Address.dart';
import '../utils/Logger.dart';
import '../utils/BinaryStream.dart';
import './raknet/Protocol.dart';
import '../Server.dart';

import 'raknet/UnconnectedPing.dart';
import 'raknet/UnconnectedPong.dart';

class RakNet {
  Logger _logger = Logger('RakNet');
  Server _server;

  RakNet(Server server) {
    this._server = server;
  }

  handleUnconnectedPacket(BinaryStream stream, Address recipient) {
    final int packetId = stream.readByte();
    stream.offset = 0;

    switch(packetId) {
      case Protocol.UnconnectedPing:
        this.handleUnconnectedPing(new UnconnectedPing().decode(stream), recipient);
        break;
      default:
        this._logger.error('Unconnected packet not yet implemented: ${packetId} (0x${packetId.toRadixString(16).padLeft(2, '0')})');
        this._logger.error(this._logger.bin(stream));
    }
  }

  handleUnconnectedPing(UnconnectedPing packet, Address recipient) {
    UnconnectedPong pong = new UnconnectedPong();
    pong.pingId = packet.pingId;
    pong.motd = this._server.motd;
    pong.playerCount = this._server.playerCount;
    pong.maxPlayers = this._server.maxPlayers;
    pong.secondaryName = 'Bedrock.dart';
    this._server.send(pong.encode(), recipient);
  }
}