import '../raknet/EncapsulatedPacket.dart';

abstract class GamePacket extends EncapsulatedPacket {

  GamePacket(int id) : super(id);

}