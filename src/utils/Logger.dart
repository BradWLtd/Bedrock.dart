import 'package:ansicolor/ansicolor.dart';

class Logger {

  String _moduleName;
  String _systemName;

  Logger(String moduleName, { String systemName: 'Bedrock.dart' }) {
    this._moduleName = moduleName;
    this._systemName = systemName;
  }

  debug(String message) {
    AnsiPen green = AnsiPen()..green();
    this._print(green('DBG'), message);
  }

  info(String message) {
    AnsiPen blue = AnsiPen()..blue();
    this._print(blue('INF'), message);
  }

  error(String message) {
    AnsiPen red = AnsiPen()..red();
    this._print(red('ERR'), message);
  }

  warn(String message) {
    AnsiPen orange = AnsiPen()..xterm(208);
    this._print(orange('WRN'), message);
  }

  _print(String type, String message) {
    AnsiPen magenta = AnsiPen()..magenta();
    AnsiPen cyan = AnsiPen()..cyan();

    print('[${magenta(this._systemName)}.${cyan(this._moduleName)}] [${type}] ${message}');
  }
}