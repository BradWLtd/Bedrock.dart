import '../../utils/BinaryStream.dart';
import '../Packet.dart';

abstract class Acknowledgement extends Packet {

  List<int> ids = [];

  Acknowledgement(int id) : super(id);

  void reset() {
    this.ids = [];
    this.setStream(new BinaryStream());
  }

  void decodeBody() {
    int count = this.getStream().readShort();
    int cnt = 0;

    for(int i = 0; i < count && !this.getStream().feof() && cnt < 4096; i++) {
      int byte = this.getStream().readByte();

      if(byte == 0) {
        int start = this.getStream().readLTriad();
        int end = this.getStream().readLTriad();

        if((end - start) > 512) {
          end = start + 512;
        }

        for(int c = start; c <= end; c++) {
          this.ids.add(c);
          cnt++;
        }
      } else {
        this.ids.add(this.getStream().readLTriad());
        cnt++;
      }
    }
  }

  void encodeBody() {
    this.ids.sort((a, b) => a - b);
    int records = 0;

    if(ids.length > 0) {
      int start = this.ids[0];
      int last = this.ids[0];

      for(final int id in this.ids) {
        if((id - last) == 1) {
          last = id;
        } else if((id - last) > 1) {
          this._add(start, last);

          start = last = id;
          records++;
        }
      }
    }

    this.getStream().writeShort(records);
  }

  void _add(int a, int b) {
    if(a == b) {
      this.getStream().writeBoolean(true);
      this.getStream().writeLTriad(a);
    } else {
      this.getStream().writeBoolean(false);
      this.getStream().writeLTriad(a);
      this.getStream().writeLTriad(b);
    }
  }

}