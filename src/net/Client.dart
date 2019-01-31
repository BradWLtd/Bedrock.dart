import 'dart:async';

import '../utils/Address.dart';
import '../Server.dart';

class Client {

  Address address;

  int mtuSize;

  Server server;

  Timer tickInterval;

  Client(Address this.address, int this.mtuSize, Server this.server) {
    const tickDuration = const Duration(milliseconds: 500);
    this.tickInterval = new Timer.periodic(tickDuration, this._tick);
  }

  _tick(Timer timer) {
    //
  }

}