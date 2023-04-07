import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:photo_frame/global_items/global_items.dart';
import 'package:photo_frame/models/categoriesModel.dart';


class SingleCatlog extends StatelessWidget {
  void Function(String) changeFramesCategory;
  void Function(String) changeFramesCategoryName;
  void Function(Color) changeAppBarColor;
  void Function(String) changeIcon;
  SingleCatlog({Key? key, required this.changeFramesCategory,required this.changeFramesCategoryName,required this.changeAppBarColor,required this.changeIcon}) : super(key: key);
  final scrollController = ScrollController(initialScrollOffset: 0);

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: GridView.count(
          controller: scrollController,
          scrollDirection: Axis.vertical,
          crossAxisCount: 1,
          mainAxisSpacing: 10,
          children: List.generate(
            GlobalItems().categoriesList.length,
                (index) => singleCategory(GlobalItems().categoriesList[index], context),
          ),
        ),
      ),
    );
  }

  Widget singleCategory(CategoriesModel categoriesList, BuildContext context) {

    return InkWell(
      highlightColor: Colors.yellow.withOpacity(0.3),
      splashColor: categoriesList.bgColor,
      onTap: () {

        changeFramesCategory(categoriesList.frameLocationName);
        changeFramesCategoryName(categoriesList.name);
        changeAppBarColor(categoriesList.bgColor);
        changeIcon(categoriesList.iconPath);


      },
      child: Container(
        decoration: BoxDecoration(
          // image: DecorationImage(
          //   image:  AssetImage(categoriesList.imagePath),
          // ),
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(10), topLeft: Radius.circular(10)),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                categoriesList.bgColor,
                categoriesList.bgColor.withOpacity(0.5)
              ]),
        ),
        // color: Colors.amber,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageIcon(
              AssetImage(categoriesList.iconPath),
              size: 40,
              color: Colors.white,
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              categoriesList.name,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}