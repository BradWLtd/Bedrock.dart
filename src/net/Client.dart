import 'dart:async';

import '../utils/Address.dart';
import 'raknet/ConnectionRequest.dart';
import 'raknet/ConnectionRequestAccepted.dart';
import 'raknet/ConnectedPing.dart';
import 'raknet/ConnectedPong.dart';
import 'raknet/Datagram.dart';
import 'raknet/EncapsulatedPacket.dart';
import 'raknet/NewIncomingConnection.dart';
import '../utils/Logger.dart';
import 'raknet/Protocol.dart';
import 'Reliability.dart';
import 'RakNet.dart';
import '../Server.dart';

class Client {

  int clientId;

  Address address;

  int mtuSize;

  RakNet _raknet;
  Server _server;

  Logger _logger = new Logger('Client');

  Timer _tickInterval;

  DateTime _lastTransaction = DateTime.now();

  int messageIndex = 0;
  int sequenceNumber = 0;
  Map<int, int> orderedIndex = {};
  Map<int, int> sequencedIndex = {};

  Datagram packetQueue = new Datagram();

  Client(Address this.address, int this.mtuSize, Server this._server, RakNet this._raknet) {
    const tickDuration = const Duration(milliseconds: 500);
    this._tickInterval = new Timer.periodic(tickDuration, this._tick);
  }

  void disconnect([ String reason = 'Client disconnection' ]) {
    this._raknet.removeClient(this);
    this._tickInterval.cancel();
  }

  void _tick(Timer timer) {
    // TODO: Last update check

    // TODO: ACK Queue send

    // TODO: NAK Queue send

    // TODO: Datagram Queue send

    // TODO: Recovery Queue send

    if(this.packetQueue.packets.length > 0) {
      this._sendPacketQueue();
    }
  }

  void _registerTransaction() {
    this._lastTransaction = DateTime.now();
  }

  void _sendPing([ int reliability = Reliability.Unreliable ]) {
    ConnectedPing packet = ConnectedPing();
    packet.sendPingTime = this._server.getTime();
    packet.reliability = reliability;

    this._queueEncapsulatedPacket(packet);
  }

  void _sendPacketQueue() {
    this.packetQueue.sequenceNumber = this.sequenceNumber++;
    // TODO: Recovery queue business

    this._server.send(this.packetQueue, this.address);
    this.packetQueue.reset();
  }

  void _addToQueue(EncapsulatedPacket packet, [ bool immediate = false ]) {
    if((this.packetQueue.byteLength + packet.getStream().length) > (this.mtuSize - 36)) {
      this._sendPacketQueue();
    }

    if(packet.needsACK) {
      // TODO: Implement this
      this._logger.error('Packet needs ACK: ${packet.getId()}');
    }

    this.packetQueue.packets.add(packet);

    if(immediate) {
      this._sendPacketQueue();
    }
  }

  void _queueEncapsulatedPacket(EncapsulatedPacket packet, [ bool immediate = false ]) {
    if(packet.getStream() == null) {
      packet.encode();
    }

    if(packet.isOrdered()) {
      packet.orderIndex = this.orderedIndex[packet.orderChannel]++;
    } else if(packet.isSequenced()) {
      packet.orderIndex = this.orderedIndex[packet.orderChannel];
      packet.sequenceIndex = this.sequencedIndex[packet.orderChannel]++;
    }

    int maxSize = this.mtuSize - 60;

    if(packet.getStream().writtenLength > maxSize) {
      // TODO: Split packet
      this._logger.error('Packet length out of range: ${packet.getId()} (${packet.getStream().length})');
    } else {
      if(packet.isReliable()) {
        packet.messageIndex = this.messageIndex++;
      }

      this._addToQueue(packet, immediate);
    }
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
      case Protocol.NewIncomingConnection:
        this._handleNewIncomingConnection(NewIncomingConnection().decode(packet.getStream()));
        break;
      case Protocol.ConnectedPing:
        this._handleConnectedPing(ConnectedPing().decode(packet.getStream()));
        break;
      case Protocol.ConnectedPong:
        this._handleConnectedPong(ConnectedPong().decode(packet.getStream()));
        break;
      default:
        this._logger.error('Got unknown EncapsulatedPacket: ${packetId} (${this._logger.byte(packetId)})');
        this._logger.error(this._logger.bin(packet.getStream()));
    }
  }

  void _handleConnectionRequest(ConnectionRequest packet) {
    this.clientId = packet.clientId;

    ConnectionRequestAccepted reply = new ConnectionRequestAccepted();
    reply.address = this.address;
    reply.pingTime = packet.sendPingTime;
    reply.pongTime = this._server.getTime();
    reply.reliability = Reliability.Unreliable;
    reply.orderChannel = 0;

    this._queueEncapsulatedPacket(reply);
  }

  void _handleNewIncomingConnection(NewIncomingConnection packet) {
    // TODO: Add state and set it to connected here
    this._sendPing();
  }

  void _handleConnectedPing(ConnectedPing packet) {
    ConnectedPong reply = new ConnectedPong();
    reply.sendPingTime = packet.sendPingTime;
    reply.sendPongTime = this._server.getTime();
    reply.reliability = Reliability.Unreliable;

    this._queueEncapsulatedPacket(reply);
  }

  void _handleConnectedPong(ConnectedPong packet) {
    // Cool!
  }
  
}