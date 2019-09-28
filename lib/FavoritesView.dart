
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'menu.dart';
import 'data.dart';
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
        appBar: buildAppBar(),
        body: Consumer<Favorites>(
          builder: (BuildContext context, Favorites favorites, Widget child) {
            return ListView.builder(
              itemCount: favorites.length + 1,
              itemBuilder: (context, i) {
                if (favorites.length > i) {
                  String url = favorites.data[i];
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
                        setState(() => favorites.remove(url)),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return FavoritesZoom(initial: i);
                          }),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        child: Hero(
                          tag: url,
                          child: CachedNetworkImage(
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
                      favorites.data = <String>[];
                      setState(() {});
                    },
                  );
                }
              },
            );
          },
        ));
  }

  AppBar buildAppBar() {
    return AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(),
        title: Text('Favorites'),
      );
  }
}

class FavoritesZoom extends StatelessWidget {
  final int initial;
  const FavoritesZoom({this.initial});
  @override
  Widget build(BuildContext context) {
    return Consumer<Favorites>(
      builder: (BuildContext context,Favorites favorites,Widget child){
        return Zoom(
          images: favorites.data,
          initial: initial<favorites.length?initial:favorites.length-1,
        );
      },
    );
  }
}
