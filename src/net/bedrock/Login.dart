import 'GamePacket.dart';
import 'Protocol.dart';

class Login extends GamePacket {

  int protocol;

  Object chainData;
  Object clientData;

  String username;
  String clientUUID;
  String xuid;
  String publicKey;

  int clientId;
  String serverAddress;

  Login() : super(Protocol.Login);

  void decodeBody() {
    this.protocol = this.getStream().readInt();
    throw new Exception(this.protocol);
  }

}