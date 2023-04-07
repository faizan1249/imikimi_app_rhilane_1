import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService{
  static String get  bannerAdUnitId{
    if(Platform.isAndroid){
      // return "ca-app-pub-6943929536423717/2690581282";
      // return 'ca-app-pub-3940256099942544/6300978111';
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    else if(Platform.isIOS){
      return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
    }
    else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get  openAppAdUnitId{
    if(Platform.isAndroid){
      return 'ca-app-pub-3940256099942544/3419835294';
    }
    else if(Platform.isIOS){
      return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
    }
    else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
      // return 'ca-app-pub-3940256099942544/8691691434';
      // return 'ca-app-pub-3398262524144530/7302408083';
      // return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
  // static String get interstitialAdUnitId {
  //   if (Platform.isAndroid) {
  //     if (kDebugMode) {
  //
  //       return 'ca-app-pub-3398262524144530/7302408083';
  //     } else {
  //       return 'ca-app-pub-3398262524144530/7302408083';
  //     }
  //   } else if (Platform.isIOS) {
  //     return '<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>';
  //   } else {
  //     throw UnsupportedError('Unsupported platform');
  //   }
  // }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      // return 'ca-app-pub-3940256099942544/5224354917';
      return 'ca-app-pub-3398262524144530/1890278469';
      // return 'ca-app-pub-6943929536423717/6729180401';
      // return 'ca-app-pub-3398262524144530/3924220953';
      // return 'ca-app-pub-3940256099942544/6300978111';
      // return 'ca-app-pub-3940256099942544/5354046379';
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_REWARDED_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) => print("Add Loaded"),
    onAdFailedToLoad: (ad, errorCode) {
      ad.dispose();
       print("Add Failed to Load: $errorCode");
    },
    onAdOpened: ((ad) => print("Add Opened")),
  );
}