import 'dart:typed_data';

import '../utils/Address.dart';
import 'Client.dart';
import '../utils/Logger.dart';
import '../utils/BinaryStream.dart';
import './raknet/Protocol.dart';
import '../Server.dart';

import 'raknet/IncompatibleProtocol.dart';
import 'raknet/OpenConnectionRequestOne.dart';
import 'raknet/OpenConnectionReplyOne.dart';
import 'raknet/OpenConnectionRequestTwo.dart';
import 'raknet/OpenConnectionReplyTwo.dart';
import 'raknet/UnconnectedPing.dart';
import 'raknet/UnconnectedPong.dart';

class RakNet {
  Logger _logger = Logger('RakNet');
  Server _server;

  Map<Address, Client> clients = {};

  RakNet(Server server) {
    this._server = server;
  }

  hasClient(Address address) {
    for(final Address addr in this.clients.keys) {
      if(addr.ip == address.ip && addr.port == address.port) return true;
    }

    return false;
  }

  handleUnconnectedPacket(BinaryStream stream, Address recipient) {
    final int packetId = new Uint8List.view(stream.buffer)[0];

    switch(packetId) {
      case Protocol.UnconnectedPing:
        this.handleUnconnectedPing(new UnconnectedPing().decode(stream), recipient);
        break;
      case Protocol.OpenConnectionRequestOne:
        this.handleOpenConnectionRequestOne(new OpenConnectionRequestOne().decode(stream), recipient);
        break;
      case Protocol.OpenConnectionRequestTwo:
        this.handleOpenConnectionRequestTwo(new OpenConnectionRequestTwo().decode(stream), recipient);
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
    pong.secondaryName = Server.SYSTEM_NAME;
    this._server.send(pong, recipient);
  }

  handleOpenConnectionRequestOne(OpenConnectionRequestOne packet, Address recipient) {
    if(packet.protocol != Protocol.ProtocolVersion) {
      this._server.send(new IncompatibleProtocol(), recipient);
    } else {
      OpenConnectionReplyOne pk = new OpenConnectionReplyOne();
      pk.mtuSize = packet.mtuSize;
      this._server.send(pk, recipient);
    }
  }

  handleOpenConnectionRequestTwo(OpenConnectionRequestTwo packet, Address recipient) {
    print(packet.port);
    print(packet.mtuSize);
    print(packet.clientId);
    if(!this.hasClient(recipient)) {
      Client client = new Client(recipient, packet.mtuSize, this._server);
      this.clients[recipient] = client;

      this._logger.debug('Created client for ${client.address.ip}:${client.address.port}');

      OpenConnectionReplyTwo pk = new OpenConnectionReplyTwo();
      pk.port = packet.port;
      pk.mtuSize = packet.mtuSize;
      this._server.send(pk, recipient);
    }
  }
}