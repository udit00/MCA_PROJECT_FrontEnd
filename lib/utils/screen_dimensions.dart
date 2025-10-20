
import 'package:flutter/material.dart';

class ScreenDimensions {
  ScreenDimensions._();

  static late double _width;
  static late double _height;
  static bool _initialized = false;

  static void init(BuildContext context) {
    if (!_initialized) {
      final size = MediaQuery.of(context).size;
      _width = size.width;
      _height = size.height;
      _initialized = true;
    }
  }

  static double get width {
    assert(_initialized, "ScreenDimensions.init(context) must be called first!");
    return _width;
  }

  static double get height {
    assert(_initialized, "ScreenDimensions.init(context) must be called first!");
    return _height;
  }
}