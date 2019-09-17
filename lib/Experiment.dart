import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'Data.dart';

class Experiment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoViewGallery.builder(
        itemCount: Provider.of<Favorites>(context).data.length,
        builder: (BuildContext context, int i) {
          return PhotoViewGalleryPageOptions.customChild(
              childSize: Size(10, 10),
              child: CachedNetworkImage(
                placeholder: (BuildContext context, String url) =>
                    CircularProgressIndicator(),
                imageUrl: Provider.of<Favorites>(context).data[i],
              ));
        },
      ),
    );
  }
}
