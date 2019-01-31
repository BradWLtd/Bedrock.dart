class Protocol {
  static const int ServerId = 925686942;

  static const List<int> Magic = [0x00, 0xff, 0xff, 0x00, 0xfe, 0xfe, 0xfe, 0xfe, 0xfd, 0xfd, 0xfd, 0xfd, 0x12, 0x34, 0x56, 0x78];

  static const int UnconnectedPing = 0x01;
  static const int UnconnectedPong = 0x1c;
  static const int ConnectionRequest = 0x09;
} 