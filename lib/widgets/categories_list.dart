import 'package:flutter/material.dart';
import 'package:photo_frame/global_items/global_items.dart';
import 'package:photo_frame/models/categoriesModel.dart';
import 'package:photo_frame/views/category_page.dart';

class CategoriesGrid extends StatelessWidget {



  final scrollController = ScrollController(initialScrollOffset: 0);
  CategoriesGrid({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: GridView.count(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
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
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CategoryPage(frameLocationName:categoriesList.frameLocationName,
        categoryName: categoriesList.name,
          bgColor:categoriesList.bgColor,
          icon: categoriesList.iconPath,
        )));
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
                // categoriesList.bgColor.withOpacity(0.5)
                categoriesList.bgColor.withOpacity(0.8)
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
