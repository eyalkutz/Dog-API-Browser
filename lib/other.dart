import 'package:flutter/material.dart';

Size getSize(GlobalKey key) {
  RenderBox renderBox = key.currentContext.findRenderObject();
  Size size = renderBox.size;
  return size;
}
