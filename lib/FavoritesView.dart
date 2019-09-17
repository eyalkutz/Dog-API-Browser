import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'Menu.dart';
import 'data.dart';
import 'other.dart';
import 'zoom.dart';

class FavoritesView extends StatefulWidget {
  @override
  _FavoritesViewState createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Menu(),
        appBar: AppBar(
          title: Text('Favorites'),
        ),
        body: ListView.builder(
          itemCount: Provider.of<Favorites>(context).data.length + 1,
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
                onDismissed: (direction) => setState(
                    () => Provider.of<Favorites>(context).data.remove(url)),
                child: InkWell(
                  onTap: () {
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
            } else {
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
