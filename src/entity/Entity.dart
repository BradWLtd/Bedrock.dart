import 'dart:io';
import 'dart:convert';

class Entity {

  int _id;

  static List<List<dynamic>> runtimeIds = jsonDecode(new File('RuntimeIDs.json').readAsStringSync());

  Entity(int this._id);

}