import 'dart:io';

import '../utils/Logger.dart';
import '../utils/BinaryStream.dart';
import './raknet/Protocol.dart';
import '../Server.dart';

import 'raknet/UnconnectedPing.dart';

class RakNet {
  Logger _logger = Logger('RakNet');
  Server _server;

  RakNet(Server server) {
    this._server = server;
  }

  handleUnconnectedPacket(BinaryStream stream, InternetAddress recipient) {
    final int packetId = stream.readByte();
    stream.offset = 0;

    switch(packetId) {
      case Protocol.UnconnectedPing:
        this.handleUnconnectedPing(new UnconnectedPing().decode(stream), recipient);
    }
  }

  handleUnconnectedPing(UnconnectedPing packet, InternetAddress recipient) {
    print(packet.pingId);
  }
}