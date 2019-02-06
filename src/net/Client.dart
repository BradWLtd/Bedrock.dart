import 'dart:async';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

import '../utils/Address.dart';
import 'bedrock/Protocol.dart' as Bedrock;
import '../utils/Logger.dart';
import 'raknet/Protocol.dart';
import 'Reliability.dart';
import 'RakNet.dart';
import '../Server.dart';

import 'raknet/ACK.dart';
import '../utils/BinaryStream.dart';
import 'raknet/ConnectionRequest.dart';
import 'raknet/ConnectionRequestAccepted.dart';
import 'raknet/ConnectedPing.dart';
import 'raknet/ConnectedPong.dart';
import 'raknet/Datagram.dart';
import 'raknet/EncapsulatedPacket.dart';
import 'raknet/GamePacketWrapper.dart';
import 'raknet/NAK.dart';
import 'raknet/NewIncomingConnection.dart';
import 'Packet.dart';

import 'bedrock/Login.dart';

class Client {

  int clientId;

  Address address;

  int mtuSize;

  RakNet _raknet;
  Server _server;

  Logger _logger = Logger('Client');

  Timer _tickInterval;

  DateTime _lastTransaction = DateTime.now();

  int messageIndex = 0;
  int sequenceNumber = 0;
  int lastSequenceNumber = 0;
  Map<int, int> orderedIndex = {};
  Map<int, int> sequencedIndex = {};

  ACK ackQueue = ACK();
  NAK nakQueue = NAK();
  Datagram packetQueue = Datagram();
  Map<int, Datagram> recoveryQueue = {};
  List<Datagram> datagramQueue = [];

  Client(Address this.address, int this.mtuSize, Server this._server, RakNet this._raknet) {
    const tickDuration = const Duration(milliseconds: 500);
    this._tickInterval = Timer.periodic(tickDuration, this._tick);
  }

  void disconnect([ String reason = 'Client disconnection' ]) {
    this._raknet.removeClient(this);
    this._tickInterval.cancel();
  }

  void _tick(Timer timer) {
    // TODO: Last update check

    if(this.ackQueue.ids.length > 0) {
      this._server.send(this.ackQueue, this.address);
      this.ackQueue.reset();
    }

    if(this.nakQueue.ids.length > 0) {
      this._server.send(this.nakQueue, this.address);
      this.nakQueue.reset();
    }

    if(this.datagramQueue.length > 0) {
      final int limit = 16;

      for(int i = 0; i < this.datagramQueue.length; i++) {
        if(i > limit) break;

        this._server.send(this.datagramQueue[i], this.address);
        this.datagramQueue.removeAt(i);
      }
    }

    // TODO: Recovery Queue send
    if(this.recoveryQueue.length > 0) {
      this.recoveryQueue.forEach((seq, pk) {
        this.datagramQueue.add(pk);
        this.recoveryQueue.remove(seq);
      });
    }

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

    int diff = datagram.sequenceNumber - this.lastSequenceNumber;

    if(this.nakQueue.ids.length > 0) {
      int index = this.nakQueue.ids.indexOf(datagram.sequenceNumber);
      if(index != -1) this.nakQueue.ids.removeAt(index);

      if(diff != 1) {
        for(int i = this.lastSequenceNumber + 1; i < datagram.sequenceNumber; i++) {
          this.nakQueue.ids.add(i);
        }
      }
    }

    this.ackQueue.ids.add(datagram.sequenceNumber);

    if(diff >= 1) {
      this.lastSequenceNumber = datagram.sequenceNumber;
    }

    for(final EncapsulatedPacket packet in datagram.packets) {
      this._handleEncapsulatedPacket(packet);
    }
  }

  void handlePacket(Packet packet) {
    this._registerTransaction();

    if(packet is EncapsulatedPacket) return this._handleEncapsulatedPacket(packet);

    if(packet is ACK) {
      this._logger.debug('GOT ACK');
      for(final int id in packet.ids) {
        if(this.recoveryQueue.containsKey(id)) this.recoveryQueue.remove(id);
      }
    }

    if(packet is NAK) {
      this._logger.debug('GOT NAK');
      for(final int id in packet.ids) {
        print(id);
        if(this.recoveryQueue.containsKey(id)) {
          this.datagramQueue.add(this.recoveryQueue[id]);
          this.recoveryQueue.remove(id);
        }
      }
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
      case Protocol.GamePacketWrapper:
        this._handleGamePacket(GamePacketWrapper().decode(packet.getStream()));
        break;
      default:
        this._logger.error('Got unknown EncapsulatedPacket: ${packetId} (${this._logger.byte(packetId)})');
        this._logger.error(this._logger.bin(packet.getStream()));
    }
  }

  void _handleConnectionRequest(ConnectionRequest packet) {
    this.clientId = packet.clientId;

    ConnectionRequestAccepted reply = ConnectionRequestAccepted();
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
    ConnectedPong reply = ConnectedPong();
    reply.sendPingTime = packet.sendPingTime;
    reply.sendPongTime = this._server.getTime();
    reply.reliability = Reliability.Unreliable;

    this._queueEncapsulatedPacket(reply);
  }

  void _handleConnectedPong(ConnectedPong packet) {
    // Cool!
  }

  void _handleGamePacket(GamePacketWrapper packet) {
    BinaryStream body = packet.getStream().slice(packet.getStream().length - 1, 1);
    List<int> payload = ZLibDecoder().decodeBytes(body.buffer.asInt8List());
    BinaryStream pStream = BinaryStream.fromString(String.fromCharCodes(payload));

    while(!pStream.feof()) {
      BinaryStream stream = BinaryStream.fromString(pStream.readString());
      final int packetId = new Uint8List.view(stream.buffer)[0];

      switch(packetId) {
        case Bedrock.Protocol.Login:
          this._handleLogin(Login().decode(stream));
          break;
        default:
          this._logger.error('Got unknown GamePacket: ${packetId} (${this._logger.byte(packetId)})');
          this._logger.error(this._logger.bin(stream));
      }
    }
  }

  void _handleLogin(Login packet) {
    this._logger.debug('Got login. Username: ${packet.username}');
  }
  
}