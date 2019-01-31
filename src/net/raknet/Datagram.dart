import 'Protocol.dart';
import '../Packet.dart';

class Datagram extends Packet {

  Datagram([ int id = Protocol.DataPacketFour ]) : super(id);

}