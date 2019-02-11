import 'dart:convert';

import 'package:corsac_jwt/corsac_jwt.dart';

import '../../utils/BinaryStream.dart';
import 'GamePacket.dart';
import 'Protocol.dart';

class Login extends GamePacket {

  int protocol;

  Map<String, dynamic> chainData;
  Map<String, dynamic> clientData;

  String username;
  String clientUUID;
  String xuid;
  String publicKey;

  int clientId;
  String serverAddress;

  Login() : super(Protocol.Login);

  void decodeBody() {
    this.protocol = this.getStream().readInt();

    BinaryStream loginStream = BinaryStream.fromString(this.getStream().readString());
    String chainJson = loginStream.readString(loginStream.readLInt());

    this.chainData = jsonDecode(chainJson);
    
    this.chainData['chain'].forEach((token) {
      Map<String, dynamic> claims = JWT.parse(token).claims;

      if(claims.containsKey('extraData')) {
        if(claims['extraData']['displayName'] != null) this.username = claims['extraData']['displayName'];
        if(claims['extraData']['identity'] != null) this.clientUUID = claims['extraData']['identity'];
        if(claims['extraData']['XUID'] != null) this.xuid = claims['extraData']['XUID'];
      }

      if(claims.containsKey('identityPublicKey')) this.publicKey = claims['identityPublicKey'];
    });

    String clientToken = loginStream.readString(loginStream.readLInt());
    this.clientData = JWT.parse(clientToken).claims;

    if(this.clientData.containsKey('ClientRandomId')) this.clientId = this.clientData['ClientRandomId'];
    if(this.clientData.containsKey('ServerAddress')) this.serverAddress = this.clientData['ServerAddress'];
  }

}