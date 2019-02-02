import 'dart:async';

import '../utils/Address.dart';
import 'raknet/ConnectionRequest.dart';
import 'raknet/Datagram.dart';
import 'raknet/EncapsulatedPacket.dart';
import '../utils/Logger.dart';
import 'raknet/Protocol.dart';
import 'RakNet.dart';

class Client {

  int clientId;

  Address address;

  int mtuSize;

  RakNet _raknet;

  Logger _logger = new Logger('Client');

  Timer _tickInterval;

  DateTime _lastTransaction = DateTime.now();

  Client(Address this.address, int this.mtuSize, RakNet this._raknet) {
    const tickDuration = const Duration(milliseconds: 500);
    this._tickInterval = new Timer.periodic(tickDuration, this._tick);
  }

  disconnect([ String reason = 'Client disconnection' ]) {
    this._raknet.removeClient(this);
    this._tickInterval.cancel();
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
      this._handleEncapsulatedPacket(packet);
    }
  }

  _handleEncapsulatedPacket(EncapsulatedPacket packet) {
    final int packetId = packet.getId();

    switch(packetId) {
      case Protocol.DisconnectionNotification:
        this.disconnect();
        break;
      case Protocol.ConnectionRequest:
        this._handleConnectionRequest(ConnectionRequest().decode(packet.getStream()));
        break;
      default:
        this._logger.info('Got EncapsulatedPacket: ${packetId} (${this._logger.byte(packetId)})');
        this._logger.info(this._logger.bin(packet.getStream()));
    }
  }

  _handleConnectionRequest(ConnectionRequest packet) {
    this.clientId = packet.clientId;

    print(this.clientId);
  }

}