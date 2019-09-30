import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  final Widget deactivatedIcon;
  final Widget activatedIcon;
  final Function onActivated;
  final Function onDeactivated;
  final Color color;
  final Function isActivated;
  const ToggleButton(
      {this.deactivatedIcon,
      this.activatedIcon,
      this.onActivated,
      this.onDeactivated,
      this.color,
      this.isActivated});
  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  _ToggleButtonState();
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: widget.color,
      child:
          widget.isActivated() ? widget.activatedIcon : widget.deactivatedIcon,
      onPressed: () => setState(() {
        if (widget.isActivated())
          widget.onDeactivated();
        else
          widget.onActivated();
      }),
    );
  }
}
