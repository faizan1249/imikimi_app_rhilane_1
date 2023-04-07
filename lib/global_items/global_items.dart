
import 'package:flutter/material.dart';
import 'package:photo_frame/models/categoriesModel.dart';

class GlobalItems{

  List<CategoriesModel> categoriesList = [
    CategoriesModel(
        name: "Birthday",
        iconPath: 'assets/categories/icons/birthday.png',
        bgColor: Colors.blue,
        frameLocationName: "birthday"
    ),
    CategoriesModel(
        name: "Christmas",
        iconPath: 'assets/categories/icons/christmas.png',
        bgColor: Colors.purple,
        frameLocationName: "christmas"),
    CategoriesModel(
        name: "Anniversary",
        iconPath: 'assets/categories/icons/anniversary.png',
        bgColor: Colors.red,
        frameLocationName: "anniversary"
    ),
    CategoriesModel(
        name: "Flower",
        iconPath: 'assets/categories/icons/flower.png',
        bgColor: Colors.orange,
        frameLocationName: "flower"),
    CategoriesModel(
        name: "Love",
        iconPath: 'assets/categories/icons/love.png',
        bgColor: Colors.pink,
        frameLocationName: "love"),
    CategoriesModel(
        name: "Night",
        iconPath: 'assets/categories/icons/night.png',
        bgColor: Colors.brown,
        frameLocationName: "night"),
    CategoriesModel(
        name: "Sunrise",
        iconPath: 'assets/categories/icons/sunrise.png',
        bgColor: Colors.orangeAccent,
        frameLocationName: "sunrise"),
    CategoriesModel(
        name: "Garden",
        iconPath: 'assets/categories/icons/garden.png',
        bgColor: Colors.green,
        frameLocationName: "garden"),
    CategoriesModel(
        name: "Under Water",
        iconPath: 'assets/categories/icons/under_water.png',
        bgColor: Colors.blue,
        frameLocationName: "underwater"),
    CategoriesModel(
        name: "Waterfall",
        iconPath: 'assets/categories/icons/waterfall.png',
        bgColor: Colors.teal,
        frameLocationName: "waterfall")
  ];
}