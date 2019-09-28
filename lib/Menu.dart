import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'data.dart';

class Menu extends StatefulWidget {
  const Menu({
    Key key,
  }) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: RefreshIndicator(
        onRefresh: () {
          setState(() {});
          return Future.delayed(Duration(seconds: 1));
        },
        child: ListView(
          padding: EdgeInsets.only(
            top: 100,
            left: 20,
            right: 20,
          ),
          children: <Widget>[
            BrightnessSwitch(),
            PrimaryColorSwitch(),
            SettingsDebugInfo(),
            FavoritesDebugInfo(),
          ],
        ),
      ),
    );
  }
}

class FavoritesDebugInfo extends StatelessWidget {
  const FavoritesDebugInfo({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<Favorites>(context).file.readAsString(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            throw snapshot.error;
          } else {
            return Text(snapshot.data);
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class SettingsDebugInfo extends StatelessWidget {
  const SettingsDebugInfo({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<Settings>(context).file.readAsString(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            throw snapshot.error;
          } else {
            return Text(snapshot.data);
          }
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class PrimaryColorSwitch extends StatelessWidget {
  const PrimaryColorSwitch({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Primary Swatch'),
        Switch(
          value: Provider.of<Settings>(context).primaryColor ==
              Colors.blueAccent,
          onChanged: (bool value) {
            if (value) {
              Provider.of<Settings>(context).primaryColor =
                  Colors.blueAccent;
            } else {
              Provider.of<Settings>(context).primaryColor =
                  Colors.redAccent;
            }
          },
        ),
      ],
    );
  }
}

class BrightnessSwitch extends StatelessWidget {
  const BrightnessSwitch({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Icon(Theme.of(context).brightness == Brightness.light
            ? Icons.brightness_high
            : Icons.brightness_3),
        Switch(
          value: Provider.of<Settings>(context).brightness ==
              Brightness.light,
          onChanged: (bool activated) {
            if (activated) {
              Provider.of<Settings>(context).brightness =
                  Brightness.light;
            } else {
              Provider.of<Settings>(context).brightness =
                  Brightness.dark;
            }
          },
        )
      ],
    );
  }
}
