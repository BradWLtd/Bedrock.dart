import 'EncapsulatedPacket.dart';
import 'Protocol.dart';

class GamePacketWrapper extends EncapsulatedPacket {

  GamePacketWrapper() : super(Protocol.GamePacketWrapper);

}