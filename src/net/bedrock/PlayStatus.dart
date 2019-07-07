import 'GamePacket.dart';
import 'Protocol.dart';

class PlayStatus extends GamePacket {
  static const int LoginSuccess = 0;
  static const int LoginFailedClient = 1;
  static const int LoginFailedServer = 2;
  static const int PlayerSpawn = 3;
  static const int LoginFailedInvalidTenant = 4;
  static const int LoginFailedVanillaEdu = 5;
  static const int LoginFailedEduVanilla = 6;
  static const int LoginFailedServerFull = 7;

  int status;

  PlayStatus() : super(Protocol.PlayStatus);

  void encodeBody() {
    this.getStream().writeInt(this.status);
  }
}
