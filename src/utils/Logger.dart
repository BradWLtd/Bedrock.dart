import 'dart:typed_data';
import 'package:ansicolor/ansicolor.dart';

import 'BinaryStream.dart';

class Logger {

  String _moduleName;
  String _systemName;

  Logger(String moduleName, [ String systemName = 'Bedrock.dart' ]) {
    this._moduleName = moduleName;
    this._systemName = systemName;
  }

  String bin(BinaryStream stream) {
    final bytes = new Uint8List.view(stream.buffer);
    final hexBytes = bytes.map((byte) => '0x${byte.toRadixString(16).padLeft(2, '0')}');

    return '[ ${hexBytes.join(', ')} ]';
  }

  void debug(dynamic message) {
    AnsiPen green = AnsiPen()..green();
    this._print(green('DBG'), message);
  }

  void info(dynamic message) {
    AnsiPen blue = AnsiPen()..blue();
    this._print(blue('INF'), message);
  }

  void error(dynamic message) {
    AnsiPen red = AnsiPen()..red();
    this._print(red('ERR'), message);
  }

  void warn(String message) {
    AnsiPen orange = AnsiPen()..xterm(208);
    this._print(orange('WRN'), message);
  }

  void _print(String type, dynamic message) {
    AnsiPen magenta = AnsiPen()..magenta();
    AnsiPen cyan = AnsiPen()..cyan();

    print('[${magenta(this._systemName)}.${cyan(this._moduleName)}] [${type}] ${message}');
  }
}