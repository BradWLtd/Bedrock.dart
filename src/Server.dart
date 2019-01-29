import 'dart:io';

import 'utils/BinaryStream.dart';
import 'utils/Logger.dart';
import 'net/RakNet.dart';

class Server {

  Logger _logger = Logger('Server');

  RakNet _rakNet;

  Server() {
    this._rakNet = RakNet(this);
  }

  listen(int port) {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, port).then((RawDatagramSocket socket) {
      this._logger.info('Listening on ${socket.address.address}:${socket.port}');

      socket.listen((RawSocketEvent e) {
        Datagram d = socket.receive();
        if(d == null) return;

        // String message = new String.fromCharCodes(d.data).trim();
        // this._logger.debug('Datagram from ${d.address.address}:${d.port}: ${message}');
        BinaryStream stream = BinaryStream.from(d.data);
        print(stream.byteStream());
      });
    });
  }

  handleOnMessage(BinaryStream stream, InternetAddress recipient) {
    final int packetId = stream.readByte();
    stream.offset = 0;

    this._rakNet.handleUnconnectedPacket(stream, recipient);
  }
}
