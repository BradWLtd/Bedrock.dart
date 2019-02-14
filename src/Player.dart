import 'utils/Address.dart';
import 'net/Client.dart';
import 'entity/Human.dart';
import 'utils/Logger.dart';

class Player extends Human {

  String username;
  String displayName;
  String uuid;
  String xuid;

  Client _client;

  Logger _logger = Logger('Player');

  Player(Client this._client) : super();

  Address getAddress() {
    return this._client.address;
  }

}