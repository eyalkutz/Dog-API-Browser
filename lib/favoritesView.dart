import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:provider/provider.dart';
import 'menu.dart';
import 'data.dart';
import 'zoom.dart';

class FavoritesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Favorites>(
        builder: (BuildContext context, Favorites favorites, Widget child) {
      return Scaffold(
          drawer: Menu(),
          appBar: buildAppBar(context, favorites),
          body: ListView.builder(
            itemCount: favorites.length + 1,
            itemBuilder: (context, i) {
              if (favorites.length > i) {
                String url = favorites.data[i];
                return Thambnail(
                  favorites: favorites,
                  index: i,
                );
              } else {
                return FlatButton(
                    padding: EdgeInsets.all(0.0),
                    child: Text('clear all'),
                    onPressed: () => favorites.empty());
              }
            },
          ));
    });
  }

  AppBar buildAppBar(BuildContext context, Favorites favorites) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: BackButton(),
      title: Text('Favorites'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.share),
          onPressed: () => Share.share(favorites.data.join(',')),
        ),
        IconButton(
          icon: Icon(Icons.import_export),
          onPressed: () => showDialog(
            context: context,
            builder: (BuildContext context) => ImportFavoritesDialog(),
          ).then((value) => favorites.data = value),
        )
      ],
    );
  }
}

class Thambnail extends StatelessWidget {
  const Thambnail({Key key, @required this.favorites, @required this.index})
      : super(key: key);

  final Favorites favorites;
  final int index;

  @override
  Widget build(BuildContext context) {
    String url = favorites.data[index];
    return Dismissible(
      background: ThambnailBackground(),
      key: Key(url),
      onDismissed: (direction) => favorites.remove(url),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return FavoritesZoom(initial: index);
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
  }
}

class ThambnailBackground extends StatelessWidget {
  const ThambnailBackground({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      alignment: Alignment.center,
      child: Text(
        'Delete',
        style: TextStyle(
          fontSize: 80.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ImportFavoritesDialog extends StatelessWidget {
  final TextEditingController controller = TextEditingController(text: '');
  ImportFavoritesDialog();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Import Favorites'),
          TextField(
            controller: controller,
          ),
          FlatButton(
            child: Text('import'),
            onPressed: () => Navigator.pop<List<String>>(
                context, controller.value.text.split(',')),
          )
        ],
      ),
    );
  }
}

class FavoritesZoom extends StatelessWidget {
  final int initial;
  const FavoritesZoom({this.initial});
  @override
  Widget build(BuildContext context) {
    return Consumer<Favorites>(
      builder: (BuildContext context, Favorites favorites, Widget child) {
        return Zoom(
          images: favorites.data,
          initial: initial < favorites.length ? initial : favorites.length - 1,
        );
      },
    );
  }
}
