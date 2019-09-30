import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'lifecycle_event_handler.dart';
import 'package:path_provider/path_provider.dart';

class Data {
  Settings settings;
  Favorites favorites;
  Data({this.favorites, this.settings});

  static Future<Data> load() async => Data(
        favorites: await Favorites.load(),
        settings: await Settings.load(),
      );
}

class Favorites extends ChangeNotifier {
  File file;
  List<String> _data;
  List<String> get data => _data;
  set data(List<String> value) {
    _data = value;
    notifyListeners();
  }

  Favorites({this.file, List<String> data}) : _data = data {
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
      onPaused: save,
    ));
  }

  void add(String value) {
    _data.add(value);
    notifyListeners();
  }

  void remove(String item) {
    _data.remove(item);
    notifyListeners();
  }

  void removeAt(int index) {
    _data.removeAt(index);
    notifyListeners();
  }

  void empty() {
    _data = <String>[];
    notifyListeners();
  }

  bool contains(String item) {
    return _data.contains(item);
  }

  int get length => _data.length;

  static Future<Favorites> load() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = directory.path;
    var file = await File('$path/favorites.txt').create();
    var rawData = await file.readAsString();
    var data = rawData.split(',');
    return Favorites(file: file, data: data);
  }

  void save() async {
    await file.writeAsString(data.join(','));
  }
}

class Settings extends ChangeNotifier {
  Settings({file, brightness, primaryColor, backgroundColor}) {
    _file = file;
    _brightness = brightness;
    _primaryColor = primaryColor;
    _backgroundColor = backgroundColor;
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
      onPaused: save,
    ));
  }

  Settings.fromJson({File file, Map<String, dynamic> json}) {
    this._file = file;
    this._brightness = Brightness.values[json['brightness']];
    this._primaryColor = Color(json['primaryColor']);
    this._backgroundColor = Color(json['backgroundColor']);
    this._cardColor = Color(json['cardColor']);
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
      onPaused: save,
    ));
  }

  Map<String, dynamic> toJson() => {
        'brightness': brightness.index,
        'primaryColor': primaryColor.value,
        'backgroundColor': backgroundColor.value,
        'cardColor': _cardColor.value
      };

  File _file;
  File get file => _file;

  Brightness _brightness;
  Brightness get brightness => _brightness;
  set brightness(value) {
    _brightness = value;
    notifyListeners();
  }

  Color _primaryColor;
  Color get primaryColor => _primaryColor;
  set primaryColor(value) {
    _primaryColor = value;
    notifyListeners();
  }

  Color _backgroundColor;
  Color get backgroundColor => _backgroundColor;
  set backgroundColor(value) {
    _backgroundColor = value;
    if (_backgroundColor != null)
      _cardColor = Color.fromRGBO(
        (_backgroundColor.red * 0.9).round(),
        (_backgroundColor.green * 0.9).round(),
        (_backgroundColor.blue * 0.9).round(),
        1.0,
      );
    else
      _cardColor = null;
    notifyListeners();
  }

  Color _cardColor;
  Color get cardColor => _cardColor;

  static Future<Settings> load() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = directory.path;
    var file = await File('$path/settings.json').create();
    var rawData = await file.readAsString();
    try {
      return Settings.fromJson(file: file, json: jsonDecode(rawData));
    } catch (e) {
      return Settings(
        file: file,
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
      );
    }
  }

  void save() async {
    Map jsonMap = toJson();
    String jsonString = jsonEncode(jsonMap);
    await _file.writeAsString(jsonString);
  }
}

Future<List<String>> randomImages(
    {breed: '', subBreed, i: 0, dynamic number: 1}) async {
  var json;
  if (number is int) {
    if (subBreed == null) {
      json = await http
          .get('https://dog.ceo/api/breed/$breed/images/random/$number');
    } else {
      json = await http.get(
          'https://dog.ceo/api/breed/$breed/$subBreed/images/random/$number');
    }
  } else if (number == 'all') {
    if (subBreed == null) {
      json = await http.get('https://dog.ceo/api/breed/$breed/images');
    } else {
      json =
          await http.get('https://dog.ceo/api/breed/$breed/$subBreed/images');
    }
  }
  var map = jsonDecode(json.body);
  if (map['status'] == 'success') {
    return map['message'].cast<String>();
  } else {
    if (i <= 5) {
      return await randomImages(i: i + 1);
    } else
      throw "Can't load image";
  }
}

Future<Map> getbreeds() async {
  var json = await http.get('https://dog.ceo/api/breeds/list/all');
  var map = jsonDecode(json.body);
  assert(map['status'] == 'success');
  return map['message'];
}
