import 'src/Server.dart';

main() {
  Server server = Server(
    // motd: 'Bedrock.dart Test Server',
    // maxPlayers: 50
  );

  server.listen(19132);
}
