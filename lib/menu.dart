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
          children: const <Widget>[
            BrightnessSwitch(),
            PrimaryColorPickerButton(),
            BackgroundColorPickerButton(),
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

class BrightnessSwitch extends StatelessWidget {
  const BrightnessSwitch({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Icon(Provider.of<Settings>(context).brightness == Brightness.light
            ? Icons.brightness_high
            : Icons.brightness_3),
        Switch(
          value: Provider.of<Settings>(context).brightness == Brightness.light,
          onChanged: (bool activated) {
            if (activated) {
              Provider.of<Settings>(context).brightness = Brightness.light;
            } else {
              Provider.of<Settings>(context).brightness = Brightness.dark;
            }
          },
        )
      ],
    );
  }
}

class PrimaryColorPickerButton extends StatelessWidget {
  const PrimaryColorPickerButton();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Primary Color:'),
        InkWell(
          onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) => PrimaryColorPickerMenu()),
          child: Container(
            decoration: BoxDecoration(
                color: Provider.of<Settings>(context).primaryColor,
                border: Border.all(
                  color: Provider.of<Settings>(context).brightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black,
                )),
            width: 50,
            height: 50,
          ),
        ),
      ],
    );
  }
}

class BackgroundColorPickerButton extends StatelessWidget {
  const BackgroundColorPickerButton();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Background Color:'),
        InkWell(
          onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) => BackgroundColorPickerMenu()),
          child: Container(
            decoration: BoxDecoration(
                color: Provider.of<Settings>(context).backgroundColor,
                border: Border.all(
                  color: Provider.of<Settings>(context).brightness ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black,
                )),
            width: 50,
            height: 50,
          ),
        ),
      ],
    );
  }
}

class PrimaryColorPickerMenu extends StatelessWidget {
  const PrimaryColorPickerMenu();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Primary Color'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Table(
            children: <TableRow>[
              _buildRow(
                context,
                <Color>[
                  Colors.blue,
                  Colors.brown,
                  Colors.yellow,
                  Colors.purple,
                  Colors.white,
                ],
              ),
              _buildRow(
                context,
                <Color>[
                  Color.fromRGBO(0, 255, 174, 1),
                  Colors.teal,
                  Colors.indigo,
                  Colors.red,
                  Colors.black,
                ],
              ),
            ],
          ),
          FlatButton(
            child: Text('default'),
            onPressed: () =>
                Provider.of<Settings>(context).primaryColor = Colors.blue,
          )
        ],
      ),
    );
  }

  TableRow _buildRow(BuildContext context, List<Color> colors) {
    List<ColorButton> buttons = colors.map((color) {
      return ColorButton(
        color: color,
        onPressed: () => Provider.of<Settings>(context).primaryColor = color,
      );
    }).toList();
    return TableRow(children: buttons);
  }
}

class BackgroundColorPickerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Background Color'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Table(
            children: <TableRow>[
              _buildRow(
                context,
                <Color>[
                  Colors.blue,
                  Colors.brown,
                  Colors.yellow,
                  Colors.purple,
                  Colors.white,
                ],
              ),
              _buildRow(
                context,
                <Color>[
                  Color.fromRGBO(0, 255, 174, 1),
                  Colors.teal,
                  Colors.indigo,
                  Colors.red,
                  Color.fromRGBO(50, 50, 50, 1.0),
                ],
              ),
            ],
          ),
          FlatButton(
            child: Text('default'),
            onPressed: () =>
                Provider.of<Settings>(context).backgroundColor = null,
          )
        ],
      ),
    );
  }

  TableRow _buildRow(BuildContext context, List<Color> colors) {
    List<ColorButton> buttons = colors.map((color) {
      return ColorButton(
        color: color,
        onPressed: () => Provider.of<Settings>(context).backgroundColor = color,
      );
    }).toList();
    return TableRow(children: buttons);
  }
}

class ColorButton extends StatelessWidget {
  final Color color;
  final Function onPressed;
  const ColorButton({this.color, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: InkWell(
        onTap: () {
          onPressed();
          Navigator.pop(context);
        },
        child: Container(
          color: color,
        ),
      ),
    );
  }
}
