import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'FavoritesView.dart';
import 'Menu.dart';
import 'data.dart';
import 'other.dart';
import 'zoom.dart';

class Breed extends StatelessWidget {
  final String breed;
  final String subBreed;
  final Future<List<String>> images;

  Breed({this.breed, this.subBreed})
      : images = randomImages(
          breed: breed,
          subBreed: subBreed,
          number: 'all',
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menu(),
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
