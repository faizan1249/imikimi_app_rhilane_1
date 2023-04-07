import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_frame/ad_mobs_service/ad_mob_service.dart';
import 'package:photo_frame/global_items/global_items.dart';
import 'package:photo_frame/models/categoriesModel.dart';
import 'package:photo_frame/views/show_my_stuff.dart';

class MyCreationGrid extends StatelessWidget {
  InterstitialAd? interstitialAd;
  MyCreationGrid({Key? key,required this.interstitialAd}) : super(key: key);


  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdMobService.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad) => interstitialAd = ad,
            onAdFailedToLoad: (LoadAdError error) => interstitialAd = null));
  }

  // void showInterstitialAd() {
  //   if (interstitialAd != null) {
  //     interstitialAd!.fullScreenContentCallback =
  //         FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
  //           ad.dispose();
  //           _createInterstitialAd();
  //         }, onAdFailedToShowFullScreenContent: (ad, error) {
  //           ad.dispose();
  //           _createInterstitialAd();
  //         });
  //     interstitialAd!.show();
  //     interstitialAd =null;
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return GridView.count(
      scrollDirection: Axis.horizontal,
      crossAxisCount: 1,
      //crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: List.generate(
        GlobalItems().categoriesList.length,
            (index) => singleMyCreation(GlobalItems().categoriesList[index],context),
      ),
    );
  }

  Widget singleMyCreation(CategoriesModel categoriesList,BuildContext context) {
    return InkWell(
      onTap: (){
        //showInterstitialAd();
        Navigator.push(context, MaterialPageRoute(builder: (context)=>MyStuff(
            frameLocationName: categoriesList.frameLocationName,
            categoryName: categoriesList.name,
            bgColor: categoriesList.bgColor,
            icon:categoriesList.iconPath
        )));
        //void showInterstitialAd() {
          if (interstitialAd != null) {
            interstitialAd!.fullScreenContentCallback =
                FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>MyStuff(
                  //     frameLocationName: categoriesList.frameLocationName,
                  //     categoryName: categoriesList.name,
                  //     bgColor: categoriesList.bgColor,
                  //     icon:categoriesList.iconPath
                  // )));

                  ad.dispose();
                  _createInterstitialAd();

                }, onAdFailedToShowFullScreenContent: (ad, error) {
                  ad.dispose();
                  _createInterstitialAd();
                });
            interstitialAd!.show();
            interstitialAd =null;
          }else{
            // print("Ad is null");
            // Navigator.push(context, MaterialPageRoute(builder: (context)=>MyStuff(
            //     frameLocationName: categoriesList.frameLocationName,
            //     categoryName: categoriesList.name,
            //     bgColor: categoriesList.bgColor,
            //     icon:categoriesList.iconPath
            // )));
          }
        //}

        // Navigator.push(context, MaterialPageRoute(builder: (context)=>MyStuff(
        //   frameLocationName: categoriesList.frameLocationName,
        //   categoryName: categoriesList.name,
        //   bgColor: categoriesList.bgColor,
        //   icon:categoriesList.iconPath
        // )));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageIcon(
              AssetImage(categoriesList.iconPath),
              size: 40,
              color: Colors.blue,
            ),
            SizedBox(height: 5,),
            Text(
              categoriesList.name,
              style: TextStyle(
                  color: Colors.blue
              ),
            ),
          ],
        ),
      ),
    );
  }
}
