import 'package:flutter/material.dart';
import 'home.dart';
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
                ChangeNotifierProvider(
                  builder: (context)=>data.favorites,
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
