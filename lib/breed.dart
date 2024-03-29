import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'favoritesView.dart';
import 'menu.dart';
import 'data.dart';
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
      appBar: buildAppBar(context),
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

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: BackButton(),
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
    return Material(
      color: Provider.of<Settings>(context).backgroundColor,
      child: GridView.builder(
        itemCount: pics.length,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: picSize),
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        itemBuilder: (context, i) {
          String image = pics[i];
          return Thambnail(
            pics: pics,
            image: image,
            i: i,
          );
        },
      ),
    );
  }
}

class Thambnail extends StatelessWidget {
  const Thambnail(
      {Key key, @required this.pics, @required this.image, @required this.i})
      : super(key: key);

  final List<String> pics;
  final String image;
  final int i;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(5.0),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Zoom(
                    images: pics,
                    initial: i,
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
    );
  }
}
