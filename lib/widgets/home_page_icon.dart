import 'package:flutter/material.dart';

class HomePageIcon extends StatelessWidget {
   HomePageIcon({Key? key,required this.iconName}) : super(key: key);


   IconData iconName;

  @override
  Widget build(BuildContext context) {
    return Icon(iconName,size: 30,color: Colors.purple,);
  }
}
