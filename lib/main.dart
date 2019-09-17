import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_play_recreation/ToggleButton.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'home.dart';
import 'lifecycle_event_handler.dart';
import 'package:share/share.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'data.dart';

main(List<String> args) {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Data.load(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return MaterialApp(
              home: Text(snapshot.error.toString()),
            );
          }
          Data data = snapshot.data;
          return MultiProvider(
              providers: [
                Provider<Favorites>.value(
                  value: data.favorites,
                ),
                ChangeNotifierProvider<Settings>(
                  builder: (context) => data.settings,
                )
              ],
              child: Consumer<Settings>(
                builder: (context, Settings settings, Widget child) {
                  return MaterialApp(
                    theme: ThemeData(
                      brightness: settings.brightness,
                      primaryColor: settings.primaryColor,
                    ),
                    home: Home(),
                  );
                },
              ));
        } else {
          return Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
