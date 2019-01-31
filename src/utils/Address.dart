enum AddressFamily {
  V4, V6
}

class Address {
  String ip;
  int port;
  AddressFamily family;

  Address(String this.ip, int this.port, AddressFamily this.family);

  bool operator ==(other) {
    if(other is! Address) return false;

    return (other.ip == this.ip && other.port == this.port);
  }
}