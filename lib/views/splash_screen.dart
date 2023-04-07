import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_frame/ad_mobs_service/ad_mob_service.dart';
import 'package:photo_frame/views/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final bgImage;
  AppOpenAd? _appOpenAd;
  bool isAdAvailable = false;
  bool _isShowingAd = false;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bgImage = AssetImage("assets/background/bgg3.jpg");
    loadAdOpenApp();
    goToHomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(""),
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                        image: AssetImage('assets/logo/logo.png')),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Text(
                  "Photo Frame App",
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          )),
    );
  }

  void showAdIfAvailable() {
    if (!isAdAvailable) {
      // print('Tried to show ad before available.');
      loadAdOpenApp();
      return;
    }
    if (_isShowingAd) {
      // print('Tried to show ad while already showing an ad.');
      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        // print('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        // print('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        // print('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAdOpenApp();
      },
    );
  }

  void loadAdOpenApp() {
    AppOpenAd.load(
      adUnitId: AdMobService.openAppAdUnitId,
      orientation: AppOpenAd.orientationPortrait,
      request: AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          // print('AppOpenAd failed to load: $error');
          // Handle the error.
        },
      ),
    );

    isAdAvailable = _appOpenAd != null ? true : false;
  }

  void goToHomeScreen() async {
    await Future.delayed(Duration(milliseconds: 1500));

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => HomePage(bgImg: bgImage)));
  }
}
