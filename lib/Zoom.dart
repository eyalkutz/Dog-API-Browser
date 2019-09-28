import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share/share.dart';
import 'package:provider/provider.dart';
import 'FavoritesView.dart';
import 'toggleButton.dart';
import 'data.dart';

class Zoom extends StatelessWidget {
  final List<String> images;
  final Key key;
  final PageController controller;
  int get current {
    try {
      return controller.page.toInt();
    } catch (e) {
      // if (!(e is AssertionError))
      //   rethrow;
      // else
      return controller.initialPage;
    }
  }

  // String get image => images[current];
  final ValueNotifier<String> image = ValueNotifier<String>(null);
  final ValueNotifier<int> index = ValueNotifier<int>(null);

  Zoom({this.images, this.key, int initial})
      : controller = PageController(initialPage: initial),
        super(key: key) {
    image.value = images[initial];
    index.value = initial;
    // _controller
    //     .addListener(() => image.value = images[_controller.page.round()]);
    controller.addListener(() => index.value = controller.page.round());
    index.addListener(() => image.value = images[index.value]);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              controller.dispose();
              Navigator.pop(context);
            },
          ),
          title: ValueListenableBuilder<int>(
            valueListenable: index,
            builder: (BuildContext context, int index, Widget child) {
              return Text(index.toString());
            },
          ),
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
              onPressed: () => Share.share(image.value),
            )
          ],
        ),
        body: PhotoViewGallery.builder(
          pageController: controller,
          itemCount: images.length,
          builder: (BuildContext context, int i) {
            return PhotoViewGalleryPageOptions(
              key: Key(images[i]),
              imageProvider: CachedNetworkImageProvider(images[i]),
              heroTag: images[i],
            );
          },
        ),
        floatingActionButton: ValueListenableBuilder<String>(
          valueListenable: image,
          builder: (BuildContext context, String image, Widget child) {
            return Consumer<Favorites>(
              builder:
                  (BuildContext context, Favorites favorites, Widget child) {
                return ToggleButton(
                  deactivatedIcon: Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                  ),
                  activatedIcon: Icon(
                    Icons.favorite,
                    color: Colors.white,
                  ),
                  onActivated: () => favorites.add(image),
                  onDeactivated: () => favorites.remove(image),
                  isActivated: () => favorites.contains(image),
                  color: Colors.red,
                );
              },
            );
          },
        ));
  }
}
