import 'dart:async';

import '../utils/Address.dart';
import 'raknet/ConnectionRequest.dart';
import 'raknet/ConnectionRequestAccepted.dart';
import 'raknet/NewIncomingConnection.dart';
import 'raknet/Datagram.dart';
import 'raknet/EncapsulatedPacket.dart';
import '../utils/Logger.dart';
import 'raknet/Protocol.dart';
import 'Reliability.dart';
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

  void disconnect([ String reason = 'Client disconnection' ]) {
    this._raknet.removeClient(this);
    this._tickInterval.cancel();
  }

  void _tick(Timer timer) {
    //
  }

  void _registerTransaction() {
    this._lastTransaction = DateTime.now();
  }

  void handlePackets(Datagram datagram) {
    this._registerTransaction();

    for(final EncapsulatedPacket packet in datagram.packets) {
      this._handleEncapsulatedPacket(packet);
    }
  }

  void _handleEncapsulatedPacket(EncapsulatedPacket packet) {
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

  void _handleConnectionRequest(ConnectionRequest packet) {
    this.clientId = packet.clientId;

    print(this.clientId);

    var reply = new ConnectionRequestAccepted();
    reply.address = this.address;
    reply.systemAddresses.add(new Address('127.0.0.1', 0, AddressFamily.V4));
    reply.pingTime = packet.sendPingTime;
    reply.reliability = Reliability.Unreliable;
    reply.orderChannel = 0;
  }

}