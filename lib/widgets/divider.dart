import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
   CustomDivider({Key? key,required this.centerOfDivider}) : super(key: key);

   Widget centerOfDivider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.blue,
            thickness: 2,
            height: 10,
          ),
        ),
        SizedBox(
          width: 5,
        ),
        centerOfDivider,
        SizedBox(
          width: 5,
        ),
        Expanded(
          child: Divider(
            color: Colors.blue,
            thickness: 2,
            height: 10,
          ),
        ),
      ],
    );
  }
}
