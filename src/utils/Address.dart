enum AddressFamily {
  V4, V6
}

class Address {
  String ip;
  int port;
  AddressFamily family;

  Address(String this.ip, int this.port, AddressFamily this.family);
}