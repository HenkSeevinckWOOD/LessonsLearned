library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//------------------------------------------------------------------------
// Corporate Anchor Colors (Add different Anchor Color combination to change the theme of the App)
Map<String, dynamic> anchorPair1 = {
  'primaryColor': const Color(0xFF000000),
  'secondaryColor': const Color(0xFFFFFFFF),
};

//------------------------------------------------------------------------
// Corporate Utility Colors
Map<String, dynamic> utilityPair1 = {
  'color1': const Color(0xFF007069),
  'color2': const Color(0xFF85E5A7),
};

Map<String, dynamic> utilityPair2 = {
  'color1': const Color(0xFF0072FD),
  'color2': const Color(0xFF00D9FF),
};

Map<String, dynamic> utilityPair3 = {
  'color1': const Color(0xFFFF7038),
  'color2': const Color(0xFFFCDF20),
};

Map<String, dynamic> utilityPair4 = {
  'color1': const Color(0xFF9E0D8F),
  'color2': const Color(0xFFFF99FF),
};

//------------------------------------------------------------------------
//Application Information
Map<String, dynamic> appInfo = {
  'name':'WOOD Projects Africa Lessons Learned',
  'description': 
'''
TBA
''',
  'version': 0.0,
  'applicationID' : 12,
};

//------------------------------------------------------------------------
//Responsive Themes, test
class ResponsiveTheme {
  final BuildContext context;

  ResponsiveTheme(this.context);

  double get header1Size => MediaQuery.of(context).size.width * 0.0115;
  double get header2Size => MediaQuery.of(context).size.width * 0.01;
  double get header3Size => MediaQuery.of(context).size.width * 0.00875;
  double get bodySize => MediaQuery.of(context).size.width * 0.00875;
  double get pageHeaderHeight => MediaQuery.of(context).size.height * 0.15;
  double get pageFooterHeight => MediaQuery.of(context).size.height * 0.075;

  Map<String, dynamic> get theme => {
    'anchorColors': anchorPair1,
    'utilityColorPair1': utilityPair1,
    'utilityColorPair2': utilityPair2,
    'utilityColorPair3': utilityPair3,
    'utilityColorPair4': utilityPair4,
    'logo': 'images/whiteWood.png',
    'font': GoogleFonts.notoSans,
    'header1Size': header1Size,
    'header2Size': header2Size,
    'header3Size': header3Size,
    'bodySize': bodySize,
    'pageHeaderHeight': pageHeaderHeight,
    'pageFooterHeight': pageFooterHeight,
  };
}
