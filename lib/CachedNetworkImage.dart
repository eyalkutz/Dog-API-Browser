import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';

///TODO: Implement my own [CachedNetworkImage] that allows you to get the image size
///and is eficiently optionally zoomable

Future CachedNetworkImage(String url) async {
  return FileImage(
    await DefaultCacheManager().getSingleFile(url)
  );
}

class Preview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CachedNetworkImage(url),
    );
  }
}