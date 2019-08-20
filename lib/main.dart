import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'lifecycle_event_handler.dart';

main(List<String> args) {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder(
      future: Favorites.load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Data(
            favorites: snapshot.data,
            child: MaterialApp(
              theme: ThemeData(brightness: Brightness.dark),
              home: Home(),
            ),
          );
        } else {
          return Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
    
  }
}

class Data extends InheritedWidget {
  final Favorites favorites;
  Data({Widget child, this.favorites}) : super(child: child){
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
    onSuspending: favorites.save,
    ));
  }
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;
  static Data of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(Data);
}



class Favorites {
  Directory directory;
  String path;
  File file;
  List<String> data;
  Favorites({this.directory, this.path, this.file, this.data}); 
  static Future<Favorites> load() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = directory.path;
    var file = await File('$path/favorites.txt').create();
    var rawData = await file.readAsString();
    var data = rawData.split(',');
    return Favorites(directory: directory, path: path, file: file, data: data);
  }

  void save()async{
    await file.writeAsString(data.join(','));
    var content = await file.readAsString();
    print(content);
  }
}



class Home extends StatefulWidget {
  Future<Map> breeds;
  final breed;

  Home([this.breed]) {
    breeds = getbreeds(breed);
  }

  static Future<Map> getbreeds([breed]) async {
    var json;
    if (breed == null) {
      json = await http.get('https://dog.ceo/api/breeds/list/all');
    } else {
      json = await http.get('https://dog.ceo/api/breed/$breed/list');
    }
    var map = jsonDecode(json.body);
    assert(map['status'] == 'success');
    if (breed == null) {
      return map['message'];
    } else {
      Map newmap = Map();
      map['message'].forEach((item) => newmap[item] = []);
      return newmap;
    }
  }

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Dogs'),
      ),
      body: FutureBuilder(
        future: widget.breeds,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              List<Category> categories = [];
              snapshot.data.forEach((key, value) => categories.add(Category(
                    breed: key,
                    subBreeds: value.cast<String>(),
                  )));
              return RefreshIndicator(
                onRefresh: () {
                  setState(() {});
                  return Future.delayed(Duration(seconds: 1));
                },
                child: ListView(
                  children: categories,
                ),
              );
            } else {
              throw snapshot.error;
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class Thambnail extends StatelessWidget {
  Thambnail({
    Key key,
    @required this.image,
    this.name,
    this.onPressed,
  }) : super(key: key);

  final Future<List<String>> image;
  final String name;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onPressed,
        child: Column(
          children: <Widget>[
            Expanded(
              child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: <Widget>[
                      Center(child: CircularProgressIndicator()),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FutureBuilder(
                            future: image,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasData) {
                                  return CachedNetworkImage(
                                    placeholder: (context, url) => Container(),
                                    imageUrl: snapshot.data[0],
                                  );
                                } else if (snapshot.hasError) {
                                  return Container(
                                    color: Colors.red,
                                    child: Center(
                                      child: Text('${snapshot.error}'),
                                    ),
                                  );
                                }
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ),
                      )
                    ],
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(name),
            ),
          ],
        ),
      ),
    );
  }
}



class Category extends StatelessWidget {
  final String breed;
  final List<String> subBreeds;
  List<Future<List<String>>> images = [];

  Category({this.breed, this.subBreeds}) {
    if (subBreeds.length > 0) {
      subBreeds.forEach((sub) => images.add(randomImages(
            breed: breed,
            subBreed: sub,
          )));
    } else {
      images.add(randomImages(breed: breed));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.0),
      height: 230,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5.0,
        child: Column(
          children: <Widget>[
            FlatButton(
              onPressed: () {
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Breed(
                            breed: breed,
                          )),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                height: 35,
                alignment: Alignment.topLeft,
                child: Text(breed),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, i) {
                  if (subBreeds.length == 0) {
                    return Thambnail(
                      image: images[i],
                      name: breed,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Breed(
                                    breed: breed,
                                  )),
                        );
                      },
                    );
                  } else {
                    return FlatButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Breed(
                                    breed: breed,
                                    subBreed: subBreeds[i],
                                  )),
                        );
                      },
                      child: Thambnail(
                        image: images[i],
                        name: subBreeds[i],
                      ),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
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
  print(json.runtimeType);
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

class Breed extends StatelessWidget {
  String breed;
  String subBreed;
  Future<List<String>> images;

  Breed({this.breed, this.subBreed}) {
    images = randomImages(
      breed: breed,
      subBreed: subBreed,
      number: 'all',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((subBreed != null) ? subBreed : breed),
      ),
      body: FutureBuilder(
        future: images,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            //return Center(child: Text('${pics}'));
            return new ImageDisplay(pics: snapshot.data);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class ImageDisplay extends StatefulWidget {
  const ImageDisplay({
    Key key,
    @required this.pics,
  }) : super(key: key);

  final List pics;

  @override
  _ImageDisplayState createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<ImageDisplay> {
  int length;
  ScrollController _controller;
  List pics;

  void scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent * 0.95 &&
        !_controller.position.outOfRange) {
      setState(() {
        if (length + 10 <= widget.pics.length) {
          length += 10;
        } else {
          length = widget.pics.length;
        }
      });
    }
  }

  @override
  void initState() {
    pics = widget.pics
        .map((image) {
          return Container(
            padding: EdgeInsets.all(8.0),
            height: 110,
            width: 110,
            //width: 100,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Zoom(
                            image: image,
                          )),
                );
              },
              child: Hero(
                tag: image,
                child: CachedNetworkImage(
                  placeholder: (context, x) =>
                      Center(child: CircularProgressIndicator()),
                  imageUrl: image,
                ),
              ),
            ),
          );
        })
        .toList()
        .cast<Container>();

    _controller = ScrollController();
    _controller.addListener(scrollListener);

    if (widget.pics.length <= 40) {
      length = widget.pics.length;
    } else {
      length = 40;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      child: Wrap(
        children: pics.getRange(0, length).toList(),
      ),
    );
  }
}

class Zoom extends StatelessWidget {
  String image;
  Key key;

  Zoom({this.image, this.key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.bookmark),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesView()),
                );
              },
            )
          ],
        ),
        body: Center(
          child: Hero(
            tag: image,
            child: CachedNetworkImage(
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              imageUrl: image,
            ),
          ),
        ),
        floatingActionButton: ToggleButton(
          deactivatedIcon: Icon(Icons.bookmark_border),
          activatedIcon: Icon(Icons.bookmark),
          onActivated: () => Data.of(context).favorites.data.add(image),
          onDeactivated: () => Data.of(context).favorites.data.remove(image),
          isActivated: () => Data.of(context).favorites.data.contains(image),
          color: Colors.blue,
        ));
  }
}

class ToggleButton extends StatefulWidget {
  final Widget deactivatedIcon;
  final Widget activatedIcon;
  final Function onActivated;
  final Function onDeactivated;
  final Color color;
  final Function isActivated;
  const ToggleButton(
      {this.deactivatedIcon,
      this.activatedIcon,
      this.onActivated,
      this.onDeactivated,
      this.color,
      this.isActivated});
  @override
  _ToggleButtonState createState() => _ToggleButtonState(isActivated);
}

class _ToggleButtonState extends State<ToggleButton> {
  Function selected;
  _ToggleButtonState(this.selected);
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: widget.color,
      child: selected() ? widget.activatedIcon : widget.deactivatedIcon,
      onPressed: () {
        if (selected()) {
          widget.onDeactivated();
        } else {
          widget.onActivated();
        }
        setState(() {});
      },
    );
  }
}

class FavoritesView extends StatefulWidget {
  @override
  _FavoritesViewState createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: ListView(
          children: <Widget>[
            ...Data.of(context).favorites.data.map((url) => CachedNetworkImage(
                  imageUrl: url,
                )),
            FlatButton(
              child: Text('clear all'),
              onPressed: () {
                Data.of(context).favorites.data = <String>[];
                setState(() {});
              },
            )
          ],
        ));
  }
}
