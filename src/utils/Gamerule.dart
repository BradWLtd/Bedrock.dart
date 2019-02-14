class GameruleType {
  static const int Boolean = 1;
  static const int Integer = 2;
  static const int Float = 3;
}

class Gamerule {

  String name;
  int type;
  dynamic value;

  Gamerule(String this.name, int this.type, dynamic this.value);

}