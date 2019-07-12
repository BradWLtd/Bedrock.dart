import 'dart:io';

import 'utils/Address.dart';
import 'utils/BinaryStream.dart';
import 'utils/Logger.dart';
import 'net/Packet.dart';
import 'net/RakNet.dart';
import 'net/raknet/Protocol.dart' as R;
import 'net/bedrock/Protocol.dart' as B;

class Server {
  static const String SYSTEM_NAME = 'Bedrock.dart';

  Logger _logger = Logger('Server');

  RakNet _rakNet;

  RawDatagramSocket _socket;

  String motd;
  int maxPlayers;

  int _startTime;
  int playerCount = 5; // Will be replaced

  // List of packet IDs to ignore when printing to/from debug logs
  List<int> _silentPackets = [
    R.Protocol.UnconnectedPing,
    R.Protocol.UnconnectedPong,
    R.Protocol.ACK,
    R.Protocol.NAK,
    R.Protocol.DataPacketFour, // Will be logged by RakNet.dart
  ];

  Server({this.motd = 'Bedrock.dart', this.maxPlayers = 20}) {
    _rakNet = RakNet(this);
  }

  void listen(int port) {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, port)
        .then((RawDatagramSocket socket) {
      _logger.info('Listening on ${socket.address.address}:${socket.port}');

      _startTime = DateTime.now().millisecondsSinceEpoch.floor();
      _socket = socket;

      socket.listen((RawSocketEvent e) {
        Datagram d = socket.receive();
        if (d == null) return;

        // String message = new String.fromCharCodes(d.data).trim();
        // this._logger.debug('Datagram from ${d.address.address}:${d.port}: ${message}');
        BinaryStream stream = BinaryStream.from(d.data);
        AddressFamily family = d.address.type == InternetAddressType.IPv4
            ? AddressFamily.V4
            : AddressFamily.V6;
        handleOnMessage(stream, new Address(d.address.address, d.port, family));
      });
    });
  }

  void handleOnMessage(BinaryStream stream, Address recipient) {
    final int packetId = stream.readByte();
    stream.offset = 0;

    if (!_silentPackets.contains(packetId)) _logger.debug('<- ${packetId}');

    _rakNet.handlePacket(stream, recipient);
  }

  int getTime() {
    return DateTime.now().millisecondsSinceEpoch.floor() - _startTime;
  }

  void send(Packet packet, Address address) {
    if (!_silentPackets.contains(packet.id)) _logger.debug('-> ${packet.id}');
    _socket.send(packet.encode().buffer.asInt8List(),
        new InternetAddress(address.ip), address.port);
  }
}
