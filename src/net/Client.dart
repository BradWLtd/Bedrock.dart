import 'dart:async';

import '../utils/Address.dart';
import 'raknet/Datagram.dart';
import 'raknet/EncapsulatedPacket.dart';
import '../utils/Logger.dart';
import 'raknet/Protocol.dart';
import '../Server.dart';

class Client {

  Address address;

  int mtuSize;

  Server _server;

  Logger _logger = new Logger('Client');

  Timer tickInterval;

  DateTime _lastTransaction = DateTime.now();

  Client(Address this.address, int this.mtuSize, Server this._server) {
    const tickDuration = const Duration(milliseconds: 500);
    this.tickInterval = new Timer.periodic(tickDuration, this._tick);
  }

  _tick(Timer timer) {
    //
  }

  _registerTransaction() {
    this._lastTransaction = DateTime.now();
  }

  handlePackets(Datagram datagram) {
    this._registerTransaction();

    for(final EncapsulatedPacket packet in datagram.packets) {
      this.handleEncapsulatedPacket(packet);
    }
  }

  handleEncapsulatedPacket(EncapsulatedPacket packet) {
    final int packetId = packet.getId();

    switch(packetId) {
      case Protocol.DisconnectionNotification:
        
        break;
      default:
        this._logger.info('Got EncapsulatedPacket: ${packetId} (${this._logger.byte(packetId)})');
        this._logger.info(this._logger.bin(packet.getStream()));
    }
  }

}