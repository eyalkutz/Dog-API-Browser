import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share/share.dart';
import 'package:provider/provider.dart';
import 'FavoritesView.dart';
import 'ToggleButton.dart';
import 'data.dart';

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
          onDeactivated: () =>
              Provider.of<Favorites>(context).data.remove(image),
          isActivated: () =>
              Provider.of<Favorites>(context).data.contains(image),
          color: Colors.red,
        ));
  }
}
