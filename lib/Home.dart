import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'Breed.dart';
import 'Data.dart';
import 'Experiment.dart';
import 'FavoritesView.dart';
import 'Menu.dart';

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
      drawer: Menu(),
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
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => Experiment())),
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
                  padding: EdgeInsets.all(8.0),
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

class Category extends StatelessWidget {
  final String breed;
  final List<String> subBreeds;
  List<Future<List<String>>> images = [];
  double height = 200;

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
            BreedButton(breed: breed),
            ThambnailList(
                height: height,
                images: images,
                subBreeds: subBreeds,
                breed: breed)
          ],
        ),
      ),
    );
  }
}

class ThambnailList extends StatelessWidget {
  const ThambnailList({
    Key key,
    @required this.height,
    @required this.images,
    @required this.subBreeds,
    @required this.breed,
  }) : super(key: key);

  final double height;
  final List<Future<List<String>>> images;
  final List<String> subBreeds;
  final String breed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth=MediaQuery.of(context).size.width;
          return OverflowBox(
            maxWidth: screenWidth,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length+2,
              itemBuilder: (context, j) {
                if(j==0 || j==images.length+1)
                  return Container(width: (screenWidth- constraints.biggest.width)/2,);
                final i=j-1;
                return Thambnail(
                  image: images[i],
                  name: subBreeds.length == 0 ? breed : subBreeds[i],
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
              },
            ),
          );
        },
      ),
    );
  }
}

class BreedButton extends StatelessWidget {
  const BreedButton({
    Key key,
    @required this.breed,
  }) : super(key: key);

  final String breed;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
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
      elevation: 10,
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