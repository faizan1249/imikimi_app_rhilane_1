
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_frame/ad_mobs_service/ad_mob_service.dart';
import 'package:photo_frame/widgets/categories_list.dart';
import 'package:photo_frame/widgets/custom_appbar.dart';
import 'package:photo_frame/widgets/divider.dart';
import 'package:photo_frame/widgets/home_page_icon.dart';
import 'package:photo_frame/widgets/my_creation_list.dart';

class HomePage extends StatefulWidget {

  HomePage({Key? key,required this.bgImg}) : super(key: key);
  AssetImage bgImg;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  InterstitialAd? interstitialAd;


  @override
  void initState() {
    _createInterstitialAd();
    // TODO: implement initState
    // print("initState");

    super.initState();

    //bgImg = AssetImage("assets/background/bg3.jpg");

  }

  @override
  void dispose() {
    //
    // dispose intersticialAd
    //
    interstitialAd?.dispose();
    super.dispose();
  }



  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdMobService.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad) => interstitialAd = ad,
            onAdFailedToLoad: (LoadAdError error) => interstitialAd = null));
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: widget.bgImg,
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          // actions: [
          //   TextButton(
          //       onPressed: () {
          //         // Navigator.push(
          //         //     context, MaterialPageRoute(builder: (context) => CategoryPage(frameLocationName:GlobalItems().categoriesList.first.frameLocationName,
          //         //     categoryName: GlobalItems().categoriesList.first.name,
          //         //     bgColor:GlobalItems().categoriesList.first.bgColor
          //         // )));
          //       },
          //       style: ButtonStyle(
          //         foregroundColor: MaterialStateProperty.all(Colors.white),
          //       ),
          //       child: Row(
          //         children: [Text("Start"), Icon(Icons.arrow_forward_sharp)],
          //       ))
          // ],
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Text("Photo Frames",style: TextStyle(fontFamily: "13",fontSize: 25),),
          flexibleSpace: Custom_AppBar(),
        ),
        body: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height:MediaQuery.of(context).size.height*0.08,),
            CustomDivider(centerOfDivider:Column(children: [HomePageIcon(iconName: Icons.widgets),SizedBox(height: 5,),Text("Categories",style: TextStyle(fontFamily: "13"))],)),
            SizedBox(height:MediaQuery.of(context).size.height*0.03,),
            SizedBox(
              height: MediaQuery.of(context).size.height*0.30,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                // child: CategoriesGrid(scrollController: scrollController),
                child: CategoriesGrid(),
              ),
            ),
            SizedBox(height:MediaQuery.of(context).size.height*0.08,),
            CustomDivider(centerOfDivider: Column(children: [HomePageIcon(iconName: Icons.games_sharp),SizedBox(height: 5,),Text("My Stuff",style: TextStyle(fontFamily: "13"))],)),
            SizedBox(height:MediaQuery.of(context).size.height*0.03,),
            SizedBox(
              height:  MediaQuery.of(context).size.height*0.15,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyCreationGrid(interstitialAd: interstitialAd),
              ),
            ),
          ],
        ),

        //body: SplashScreen(),

      ),
    );
  }
}
