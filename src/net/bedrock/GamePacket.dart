import '../Packet.dart';

abstract class GamePacket extends Packet {
  GamePacket(int id) : super(id);
}
