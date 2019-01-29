import 'dart:io';

import 'utils/Address.dart';
import 'utils/BinaryStream.dart';
import 'utils/Logger.dart';
import 'net/RakNet.dart';

class Server {

  Logger _logger = Logger('Server');

  RakNet _rakNet;

  RawDatagramSocket _socket;

  Server() {
    this._rakNet = RakNet(this);
  }

  listen(int port) {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, port).then((RawDatagramSocket socket) {
      this._logger.info('Listening on ${socket.address.address}:${socket.port}');

      this._socket = socket;

      socket.listen((RawSocketEvent e) {
        Datagram d = socket.receive();
        if(d == null) return;

        // String message = new String.fromCharCodes(d.data).trim();
        // this._logger.debug('Datagram from ${d.address.address}:${d.port}: ${message}');
        BinaryStream stream = BinaryStream.from(d.data);
        AddressFamily family = d.address.type == InternetAddressType.IPv4 ? AddressFamily.V4 : AddressFamily.V6;
        this.handleOnMessage(stream, new Address(d.address.address, d.port, family));
      });
    });
  }

  handleOnMessage(BinaryStream stream, Address recipient) {
    final int packetId = stream.readByte();
    stream.offset = 0;

    this._rakNet.handleUnconnectedPacket(stream, recipient);
  }

  send(BinaryStream stream, Address address) {
    this._socket.send(stream.buffer.asInt8List(), new InternetAddress(address.ip), address.port);
  }
}
