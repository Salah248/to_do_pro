import 'package:flutter/material.dart';

// This Class SizeConfig is used to get the size of the screen
// and use it to make the UI responsive to different screen sizes
class SizeConfig {
  // _mediaQueryData is used to get the size of the screen
  // screenWidth and screenHeight is used to get the width and height of the screen
  // defaultSize is used to get the default size of the screen
  // orientation is used to get the orientation of the screen (landscape or portrait)
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  //static late double defaultSize;
  static late Orientation orientation;

  // init is used to initialize the values of the variables
  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    print('$screenWidth');
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
  }
}

// Get the proportionate height as per screen size
double getProportionateScreenHeight(double inputHeight) {
  final double screenHeight = SizeConfig.screenHeight;
  // 812 is the layout height that designer use
  return (inputHeight / 812.0) * screenHeight;
}

// Get the proportionate height as per screen size
double getProportionateScreenWidth(double inputWidth) {
  final double screenWidth = SizeConfig.screenWidth;
  // 375 is the layout width that designer use
  return (inputWidth / 375.0) * screenWidth;
}
