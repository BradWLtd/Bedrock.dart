import 'dart:io';

import '../utils/Logger.dart';
import '../utils/BinaryStream.dart';
import './raknet/Protocol.dart';
import '../Server.dart';

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
        this.handleUnconnectedPing()
    }
  }
}