import 'dart:io';
import 'dart:convert';

import 'utils/Logger.dart';

class Server {

  Logger _logger = Logger('Server');

  Server() {
    
  }

  listen(int port) {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, port).then((RawDatagramSocket socket) {
      this._logger.info('Listening on ${socket.address.address}:${socket.port}');

      socket.listen((RawSocketEvent e) {
        Datagram d = socket.receive();
        if(d == null) return;

        String message = new String.fromCharCodes(d.data).trim();
        this._logger.debug('Datagram from ${d.address.address}:${d.port}: ${message}');
      });
    });
  }
}
