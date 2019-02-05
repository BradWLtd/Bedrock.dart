import 'dart:typed_data';

import '../utils/Address.dart';
import '../utils/BinaryStream.dart';
import '../utils/BitFlag.dart';
import 'Client.dart';
import '../utils/Logger.dart';
import 'raknet/Protocol.dart';
import '../Server.dart';

// Packets
import 'raknet/ACK.dart';
import 'raknet/Datagram.dart';
import 'raknet/IncompatibleProtocol.dart';
import 'raknet/NAK.dart';
import 'raknet/OpenConnectionRequestOne.dart';
import 'raknet/OpenConnectionReplyOne.dart';
import 'raknet/OpenConnectionRequestTwo.dart';
import 'raknet/OpenConnectionReplyTwo.dart';
import 'raknet/UnconnectedPing.dart';
import 'raknet/UnconnectedPong.dart';

class RakNet {
  Logger _logger = Logger('RakNet');
  Server _server;

  Set<Client> clients = new Set();

  RakNet(Server server) {
    this._server = server;
  }

  Client getClient(Address address) {
    for(final Client client in this.clients) {
      if(client.address == address) return client;
    }

    return null;
  }

  void removeClient(Client client) {
    this.clients.remove(client);
    this._logger.info('Client disconnected: ${client.address.ip}:${client.address.port}');
  }

  handlePacket(BinaryStream stream, Address recipient) {
    final int packetId = new Uint8List.view(stream.buffer)[0];

    Client client = this.getClient(recipient);
    if(client != null) {
      if((packetId & BitFlag.Valid) == 0) {
        this._logger.debug('Ignored invalid packet: ${packetId}');
        return;
      }

      if(packetId & BitFlag.ACK > 0) {
        client.handlePacket(ACK().decode(stream));
      } else if(packetId & BitFlag.NAK > 0) {
        client.handlePacket(NAK().decode(stream));
      } else {
        Datagram datagram = Datagram().decode(stream);

        client.handlePackets(datagram);
      }
    } else {
      this._handleUnconnectedPacket(stream, recipient);
    }
  }

  _handleUnconnectedPacket(BinaryStream stream, Address recipient) {
    final int packetId = new Uint8List.view(stream.buffer)[0];

    switch(packetId) {
      case Protocol.UnconnectedPing:
        this._handleUnconnectedPing(new UnconnectedPing().decode(stream), recipient);
        break;
      case Protocol.OpenConnectionRequestOne:
        this._handleOpenConnectionRequestOne(new OpenConnectionRequestOne().decode(stream), recipient);
        break;
      case Protocol.OpenConnectionRequestTwo:
        this._handleOpenConnectionRequestTwo(new OpenConnectionRequestTwo().decode(stream), recipient);
        break;
      default:
        this._logger.error('Unconnected packet not yet implemented: ${packetId} (0x${packetId.toRadixString(16).padLeft(2, '0')})');
        this._logger.error(this._logger.bin(stream));
    }
  }

  _handleUnconnectedPing(UnconnectedPing packet, Address recipient) {
    UnconnectedPong pong = new UnconnectedPong();
    pong.pingId = packet.pingId;
    pong.motd = this._server.motd;
    pong.playerCount = this._server.playerCount;
    pong.maxPlayers = this._server.maxPlayers;
    pong.secondaryName = Server.SYSTEM_NAME;
    this._server.send(pong, recipient);
  }

  _handleOpenConnectionRequestOne(OpenConnectionRequestOne packet, Address recipient) {
    if(packet.protocol != Protocol.ProtocolVersion) {
      this._server.send(new IncompatibleProtocol(), recipient);
    } else {
      OpenConnectionReplyOne pk = new OpenConnectionReplyOne();
      pk.mtuSize = packet.mtuSize;
      this._server.send(pk, recipient);
    }
  }

  _handleOpenConnectionRequestTwo(OpenConnectionRequestTwo packet, Address recipient) {
    if(this.getClient(recipient) == null) {
      Client client = new Client(recipient, packet.mtuSize, this._server, this);
      this.clients.add(client);

      this._logger.debug('Created client for ${client.address.ip}:${client.address.port}');

      OpenConnectionReplyTwo pk = new OpenConnectionReplyTwo();
      pk.port = packet.port;
      pk.mtuSize = packet.mtuSize;
      this._server.send(pk, recipient);
    }
  }
}