import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'lifecycle_event_handler.dart';
import 'package:share/share.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

main(List<String> args) {
  runApp(AppData());
}

class AppData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadData(),
      builder: (BuildContext context,AsyncSnapshot snapshot){
        if(snapshot.connectionState==ConnectionState.done){
          Data data=snapshot.data;
          return MultiProvider(
            providers: <Provider>[
              Provider<Favorites>.value(value: data.favorites,),
              Provider<Settings>.value(value: data.settings,)
            ],
            child: App(),
          );
        }
        else{
          return Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ); 
        }
      },
    );
  }

  Future<Data> _loadData() async{
    return Data(
      favorites: await Favorites.load(),
      settings: await Settings.load(),
    );
  }
}

class Data{
  Settings settings;
  Favorites favorites;
  Data({this.favorites,this.settings});
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Provider.of<Settings>(context).brightness
      ),
      home: Home(),
    );
  }
}

class Favorites {
  File file;
  List<String> data;
  Favorites({this.file, this.data}){
    WidgetsBinding.instance.addObserver(LifecycleEventHandler(
      onPaused: save,
    ));
  }

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

class Settings {
  Brightness brightness=Brightness.dark;
  static Future<Settings> load() async{
    //TODO: implement [load] and [save] methods for [Settings]
    return Settings();
  }
}

class Home extends StatefulWidget {
  final Future<Map> breeds = getbreeds();

  Home();

  static Future<Map> getbreeds() async {
    var json = await http.get('https://dog.ceo/api/breeds/list/all');
    var map = jsonDecode(json.body);
    assert(map['status'] == 'success');
    return map['message'];
  }

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 150,
                horizontal: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(Theme.of(context).brightness==Brightness.light?Icons.brightness_high:Icons.brightness_3),
                  Switch(
                    value: false,
                    onChanged: (bool activated){
                      if(activated){
                        Provider.of<Settings>(context).brightness=Brightness.light;
                      }
                      else{
                        Provider.of<Settings>(context).brightness=Brightness.dark;
                      }
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Dogs'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesView()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.code),
            onPressed:()=> Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=>Experiment())
              ),
          )
        ],
      ),
      body: FutureBuilder(
        future: widget.breeds,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return RefreshIndicator(
                onRefresh: () {
                  setState(() {});
                  return Future.delayed(Duration(seconds: 1));
                },
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, i) {
                    return Category(
                      breed: snapshot.data.keys.elementAt(i),
                      subBreeds:
                          snapshot.data.values.elementAt(i).cast<String>(),
                    );
                  },
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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesView()),
              );
            },
          )
        ],
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

Size getSize(GlobalKey key) {
  RenderBox renderBox = key.currentContext.findRenderObject();
  Size size = renderBox.size;
  return size;
}

class ImageDisplay extends StatelessWidget {
  const ImageDisplay({
    Key key,
    @required this.pics,
  }) : super(key: key);

  final List<String> pics;

  @override
  Widget build(BuildContext context) {
    double picSize = MediaQuery.of(context).size.width / 3;
    return GridView.builder(
      itemCount: pics.length,
      gridDelegate:
          SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: picSize),
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      itemBuilder: (context, i) {
        String image = pics[i];
        GlobalKey imageKey = GlobalKey();
        return FlatButton(
          padding: EdgeInsets.all(5.0),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Zoom(
                          imageSize: getSize(imageKey),
                          image: image,
                        )),
              );
            },
            child: Hero(
              tag: image,
              child: CachedNetworkImage(
                key: imageKey,
                placeholder: (context, x) =>
                    Center(child: CircularProgressIndicator()),
                imageUrl: image,
              ),
            ),
          
        );
      },
    );
  }
}

class Zoom extends StatelessWidget {
  final String image;
  final Key key;
  final Size imageSize;

  const Zoom({this.image, this.key, this.imageSize}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    assert(imageSize != null);
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesView()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () => Share.share(image),
            )
          ],
        ),
        body: Center(
          child: Container(
            child: PhotoView.customChild(
              childSize: imageSize,
              child: Hero(
                tag: image,
                child: CachedNetworkImage(
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  imageUrl: image,
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: ToggleButton(
          deactivatedIcon: Icon(
            Icons.favorite_border,
            color: Colors.white,
          ),
          activatedIcon: Icon(
            Icons.favorite,
            color: Colors.white,
          ),
          onActivated: () => Provider.of<Favorites>(context).data.add(image),
          onDeactivated: () => Provider.of<Favorites>(context).data.remove(image),
          isActivated: () => Provider.of<Favorites>(context).data.contains(image),
          color: Colors.red,
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
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  _ToggleButtonState();
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: widget.color,
      child: widget.isActivated() ? widget.activatedIcon : widget.deactivatedIcon,
      onPressed: () {
        if (widget.isActivated()) {
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
        appBar: AppBar(
          title: Text('Favorites'),
        ),
        body: ListView.builder(
          itemCount: Provider.of<Favorites>(context).data.length+1,
          itemBuilder: (context, i) {
            if (Provider.of<Favorites>(context).data.length > i) {
              String url = Provider.of<Favorites>(context).data[i];
              GlobalKey imageKey = GlobalKey();
              return Dismissible(
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.center,
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 80.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                key: Key(url),
                onDismissed: (direction) =>
                    setState(() => Provider.of<Favorites>(context).data.remove(url)),
                child: FlatButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Zoom(
                                imageSize: getSize(imageKey),
                                image: url,
                              )),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    child: Hero(
                      tag: url,
                      child: CachedNetworkImage(
                        key: imageKey,
                        fit: BoxFit.fitWidth,
                        imageUrl: url,
                      ),
                    ),
                  ),
                ),
              );
            }
            else{
              return FlatButton(
                padding: EdgeInsets.all(0.0),
                child: Text('clear all'),
                onPressed: () {
                  Provider.of<Favorites>(context).data = <String>[];
                  setState(() {});
                },
              );
            }
          },
        ));
  }
}

class Experiment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoViewGallery.builder(
        itemCount: Provider.of<Favorites>(context).data.length,
        builder: (BuildContext context,int i){
          return PhotoViewGalleryPageOptions.customChild(
            childSize: Size(10,10),
            child: CachedNetworkImage(
              placeholder: (BuildContext context,String url)=>CircularProgressIndicator(),
              imageUrl: Provider.of<Favorites>(context).data[i],
            )
          );
        },
      ),
    );
  }
}