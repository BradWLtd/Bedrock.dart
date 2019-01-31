class Protocol {
  static const int ServerId = 925686942;
  static const int ProtocolVersion = 5;
  static const String BedrockVersion = '1.8.1';

  static const List<int> Magic = [0x00, 0xff, 0xff, 0x00, 0xfe, 0xfe, 0xfe, 0xfe, 0xfd, 0xfd, 0xfd, 0xfd, 0x12, 0x34, 0x56, 0x78];

  static const int UnconnectedPing = 0x01; // 1

  static const int OpenConnectionRequestOne = 0x05; // 5
  static const int OpenConnectionReplyOne = 0x06; // 6

  static const int ConnectionRequest = 0x09; // 9

  static const int IncompatibleProtocol = 0x19; // 25

  static const int UnconnectedPong = 0x1c; // 28
} 