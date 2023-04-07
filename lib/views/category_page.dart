import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:io' as io;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_frame/ad_mobs_service/ad_mob_service.dart';
import 'package:photo_frame/models/frame_detail_model.dart';
import 'package:photo_frame/views/single_frame.dart';
import 'package:photo_frame/widgets/categories_list_verticle.dart';

class CategoryPage extends StatefulWidget {
  String frameLocationName;
  String categoryName;
  Color bgColor;
  String icon;
  BannerAd? bannerAd;

  CategoryPage(
      {Key? key,
      required this.frameLocationName,
      required this.categoryName,
      required this.bgColor,
      required this.icon})
      : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<String> imageNames = [];
  List<ImgDetails> framesDetails = [];
  int localFramesCount = 0;
  final _firestorage = FirebaseStorage.instance;

  @override
  void initState() {
    _createBannerAd();
    loadFrames();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    log("Dispose calling");
  }

  void _createBannerAd() {
    widget.bannerAd = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdMobService.bannerAdUnitId.toString(),
        listener: AdMobService.bannerAdListener,
        request: const AdRequest())
      ..load();
  }
  //
  // Future<void> reloadStorage() async {
  //   final FirebaseStorage storage = FirebaseStorage.instance;
  //   await storage.setMaxDownloadRetryTime(Duration.zero);
  //   await storage.setMaxUploadRetryTime(Duration.zero);
  //   await storage.ref().child('/').listAll();
  // }

  void loadFrames() {


    // log("loadFrames calling");
    // _firestorage.ref().child('/').listAll();
    log("widget.frameLocationName = ${widget.frameLocationName}");

    log("framesDetails length = ${framesDetails.length}");
    loadFramesFromAssets();
  }

  loadFramesFromAssets() async {
    framesDetails = [];
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // log(json.decode(manifestContent).toString());
    final imagePaths = manifestMap.keys
        .where((String key) => key.contains(
            'assets/categories/frames/' + widget.frameLocationName + '/' ) && (key.endsWith('.png') || key.endsWith('.PNG')))
        .toList();

    // imageNames = imagePaths;

    // log(widget.frameLocationName);
    for (int i = 0; i < imagePaths.length; i++) {
      framesDetails.add(ImgDetails(
          path: imagePaths[i],
          category: 'assets',
          // frameName: imagePaths[i].split(Platform.pathSeparator).last));
          frameName: imagePaths[i]));
    }

    setState(() {});
    // print("Getting Length = " + imageNames.length.toString());
    loadFramesFromLocal();
  }

  void loadFramesFromLocal() async {
    String namePrefix = widget.frameLocationName + "%2F";
    // +
    // widget.bannerModel.frameLocationName;
    final String dir = (await getApplicationDocumentsDirectory()).path;
    io.Directory("$dir").listSync().forEach((element) {
      log(element.path);
      if (element.path.contains(namePrefix)) {
        framesDetails.add(ImgDetails(
            path: element.path,
            category: 'local',
            frameName: element.path.split(Platform.pathSeparator).last));
      }
      ;
    });

    setState(() {});

    // bool result = await InternetConnectionChecker().hasConnection;
    // if (result) {
    //
    // loadFramesFromCloud();
    // bool result = await InternetConnectionChecker().hasConnection;
    if (await InternetConnectionChecker().hasConnection) {
      loadFramesFromCloud();
    }
    //
    // }
  }

  void loadFramesFromCloud() async {
    // print("Cloud reference name = " +widget.bannerModel.cloudReferenceName);
    // print("Frame location name = " + widget.frameLocationName);
    localFramesCount = framesDetails.length;



    // final _firestorage = FirebaseStorage.instance;
    final refs =
        await _firestorage.ref('frames/${widget.frameLocationName}').list();

    for (Reference ref in refs.items) {



      log("Inside For Loop name = ${widget.frameLocationName}");


      String url = await ref.getDownloadURL();
      bool isFrameFoundLocally = false;

      log(url);

      for (int i = 0; i < localFramesCount; i++) {
        if (url.contains(framesDetails[i].frameName)) {
          // log("Frame found Locally");
          isFrameFoundLocally = true;
        }
      }

      if (isFrameFoundLocally == false) {
        
        if(url.contains(widget.frameLocationName)){
          framesDetails
              .add(ImgDetails(path: url, category: 'cloud', frameName: ref.name));   
        }
        // framesDetails
        //     .add(ImgDetails(path: url, category: 'cloud', frameName: ref.name));
        // log("Frames Found");
        setState(() {});
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.bgColor.withOpacity(0.6),
        centerTitle: true,
        title: Row(
          children: [
            Expanded(
              child: Text(widget.categoryName,
                  style: TextStyle(fontFamily: "13", fontSize: 25)),
            ),
            Expanded(
              child: ImageIcon(
                AssetImage(widget.icon),
                size: 40,
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: SingleCatlog(
                changeIcon: (iconPath) {
                  widget.icon = iconPath;
                },
                changeFramesCategory: (frameLocationName) {

                  if(widget.frameLocationName != frameLocationName){
                    log(frameLocationName);
                    // clearVariables();
                    widget.frameLocationName = frameLocationName;
                    loadFrames();
                  }

                },
                changeFramesCategoryName: (framesCategoryName) {

                  if(widget.categoryName != framesCategoryName){
                    log(framesCategoryName);
                    widget.categoryName = framesCategoryName;
                  }


                },
                changeAppBarColor: (color) {

                  if(widget.bgColor != color){
                    widget.bgColor = color;
                  }

                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FramesGrid(
                  framesDetail: framesDetails,
                  imageNames: imageNames,
                  frameLocationName: widget.frameLocationName,
                  noTxtColor: widget.bgColor),
              //child: Container(color: Colors.red,),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.bannerAd == null
          ? null
          : Container(
              //margin: const EdgeInsets.only(bottom: 12),
              height: 60,
              child: AdWidget(ad: widget.bannerAd!),
            ),
    );
  }
}

class FramesGrid extends StatefulWidget {
  List<String> imageNames;
  String frameLocationName;
  Color noTxtColor;
  List<ImgDetails> framesDetail;
  Map<int, bool> isDownloading = {};

  FramesGrid(
      {Key? key,
      required this.framesDetail,
      required this.imageNames,
      required this.frameLocationName,
      required this.noTxtColor})
      : super(key: key);

  @override
  State<FramesGrid> createState() => _FramesGridState();
}

class _FramesGridState extends State<FramesGrid> {
  bool isRewardedAdLoaded = false;

  RewardedAd? rewardedAd;

  // int _numRewardedLoadAttempts = 0;

  int maxFailedLoadAttempts = 3;

  final scrollController = ScrollController(initialScrollOffset: 0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.framesDetail = [];
    log("init state calling");
    _createRewardedAd();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    log("didChangeDependencies calling");
  }

  @override
  Widget build(BuildContext context) {
    log("widget.framesDetail.length = ${widget.framesDetail.length}");
    return Scrollbar(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child:
            // imageNames.length!=0?
            widget.framesDetail.length != 0
                ? GridView.count(
                    childAspectRatio: 0.6,
                    controller: scrollController,
                    scrollDirection: Axis.vertical,
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: List.generate(
                      // imageNames.length,
                      widget.framesDetail.length,
                      // (index) => singleFrame(context, imageNames[index], frameLocationName),
                      (index) => singleFrame(
                          context,
                          widget.framesDetail[index],
                          widget.framesDetail[index].frameName,
                          widget.frameLocationName,
                          index),
                    ),
                  )
                : Center(
                    child: Text(
                      "No Frame Found",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.noTxtColor),
                    ),
                  ),
      ),
    );
  }

  Widget singleFrame(BuildContext context, ImgDetails frameDetail, imageNames,
      frameLocationName, index) {
    if (widget.isDownloading[index] == null) {
      widget.isDownloading[index] = false;
    }

    return widget.isDownloading[index]!
        ? Center(child: CircularProgressIndicator(color: Colors.blue))
        : frameDetail.category != 'cloud'
            ? InkWell(
                highlightColor: Colors.lightBlueAccent.withOpacity(0.3),
                // splashColor: Colors.blue,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SingleFrame(
                                imageNames: imageNames,
                                frameLocationName: frameLocationName,
                                frameLocationType: frameDetail.category,
                                // frameDetails: frameDetail,
                                // pathOfSeletedFrame: ,
                                singleFrameDetails: frameDetail,
                                framesDetailss: widget.framesDetail,
                              ))).then((value) => {setState(() {})});
                },
                // child: Image.asset(
                //     imageNames,
                //     //scale: 1.0,
                //   fit: BoxFit.fitHeight,
                // ),

                child: Container(
                    child: frameDetail.category == 'assets'
                        ? Image(
                            image: AssetImage(frameDetail.path),
                            fit: BoxFit.cover,
                          )
                        : Image(
                            image: FileImage(File(frameDetail.path)),
                            fit: BoxFit.cover,
                          )
                    // decoration: BoxDecoration(
                    //   image: DecorationImage(
                    //       image: AssetImage(imageNames),
                    //       // fit: BoxFit.cover
                    //       fit: BoxFit.cover),
                    // ),
                    ),
              )
            : Stack(children: [
                InkWell(
                  highlightColor: Colors.lightBlueAccent.withOpacity(0.3),
                  // splashColor: Colors.blue,
                  onTap: () {
                    downloadFrame(frameDetail.frameName, index, context);
                  },
                  child: CachedNetworkImage(
                    imageUrl: frameDetail.path,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => Center(
                            child: CircularProgressIndicator(
                                color: Colors.orange,
                                value: downloadProgress.progress)),
                    imageBuilder: (context, imageProvider) => Ink(
                      decoration: BoxDecoration(
                        // borderRadius: BorderRadius.only(
                        //   bottomLeft: index % 2 == 1
                        //       ? Radius.circular(0)
                        //       : Radius.circular(30),
                        //   bottomRight: index % 2 == 0
                        //       ? Radius.circular(0)
                        //       : Radius.circular(30),
                        //   topLeft: Radius.circular(30),
                        //   topRight: Radius.circular(30),
                        // ),
                        image: DecorationImage(
                          // image: NetworkImage(frameDetail.path),
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: index % 2 == 1 ? null : 10,
                  left: index % 2 == 1 ? 10 : null,
                  child: IgnorePointer(
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            bottomLeft: index % 2 == 1
                                ? Radius.circular(0)
                                : Radius.circular(10),
                            bottomRight: index % 2 == 0
                                ? Radius.circular(0)
                                : Radius.circular(10),
                            topLeft: index % 2 == 1
                                ? Radius.circular(10)
                                : Radius.circular(0),
                            topRight: index % 2 == 0
                                ? Radius.circular(10)
                                : Radius.circular(0),
                          )),
                      child: Icon(
                        index % 2 == 0 ? Icons.download : Icons.lock,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ]);
  }

  Future downloadFrame(imageNames, int index, BuildContext context) async {
    if (index % 2 == 1) {
      // showWatchVideoDialogBox(context);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                height: 200,
                child: Column(
                  children: [
                    AppBar(
                      title: Text("Download"),
                      backgroundColor: Colors.lightBlue,
                      automaticallyImplyLeading: false,
                    ),
                    Container(
                      height: 15,
                      color: Colors.lightBlue.withOpacity(0.6),
                    ),
                    Container(
                      height: 15,
                      color: Colors.lightBlue.withOpacity(0.4),
                    ),
                    SizedBox(height: 15),
                    Center(
                      child: Text(
                        "Would you like to unlock frame ? ",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("No")),
                        ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              // _createRewardedAd();
                              if (await _showRewardedAd()) {

                                downloadSingleFrame(index, imageNames);
                              } else {
                                // widget.changeFrame(await downloadSingleFrame(index,frameDetail.frameName));
                              }
                            },
                            child: Text("Watch Ad")),
                      ],
                    )
                  ],
                ),
              ),
            );
          });

      // print("It is Locked Frame: $index");
      //
      // // log(isRewardedAdLoaded.toString());
      // if (isRewardedAdLoaded == true) {
      //   showModalBottomSheet(
      //       context: context,
      //       builder: (context) {
      //         return StatefulBuilder(
      //             builder: ((BuildContext context, StateSetter setState) {
      //           return Container(
      //             height: 310,
      //             child: Container(
      //               padding: EdgeInsets.only(top: 20),
      //               width: MediaQuery.of(context).size.width * 0.90,
      //               child: Column(
      //                 children: [
      //                   const Text(
      //                     "Choose Your Option",
      //                     style: TextStyle(
      //                         fontWeight: FontWeight.bold, fontSize: 24),
      //                   ),
      //                   const SizedBox(
      //                     height: 20,
      //                   ),
      //                   Row(
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
      //                     children: [
      //                       InkWell(
      //                         onTap: () {
      //                           Navigator.pop(context);
      //                         },
      //                         child: Container(
      //                           decoration: BoxDecoration(
      //                               color: Colors.blue,
      //                               borderRadius: BorderRadius.circular(10)),
      //                           width: MediaQuery.of(context).size.width * .39,
      //                           height:
      //                               MediaQuery.of(context).size.height * .21,
      //                           child: Column(
      //                             mainAxisAlignment: MainAxisAlignment.center,
      //                             children: <Widget>[
      //                               Container(
      //                                 width: MediaQuery.of(context).size.width *
      //                                     .85,
      //                                 child: const Icon(
      //                                   Icons.close,
      //                                   color: Colors.white,
      //                                   size: 110,
      //                                 ),
      //                               ),
      //                               const Text(
      //                                 "May be Later",
      //                                 style: TextStyle(
      //                                     fontWeight: FontWeight.bold,
      //                                     color: Colors.white,
      //                                     fontSize: 18),
      //                               ),
      //                             ],
      //                           ),
      //                         ),
      //                       ),
      //                       InkWell(
      //                         onTap: () async {
      //                           // _createRewardedAd();
      //
      //                           Navigator.pop(context);
      //                           if(await _showRewardedAd()){
      //                           // if(isRewardedAdLoaded){
      //                             if(await InternetConnectionChecker().hasConnection){
      //                               downloadSingleFrame(index, imageNames);
      //                             }else{
      //                               Fluttertoast.showToast(msg: "Check internet Connection",backgroundColor: Colors.red);
      //                             }
      //
      //                           }
      //
      //                           // else{
      //                           //   log("Else");
      //                           //   if(await InternetConnectionChecker().hasConnection){
      //                           //     downloadSingleFrame(index, imageNames);
      //                           //   }else{
      //                           //     Fluttertoast.showToast(msg: "Check internet Connection",backgroundColor: Colors.red);
      //                           //   }
      //                           // }
      //                         },
      //                         child: Container(
      //                           decoration: BoxDecoration(
      //                               color: Colors.blue,
      //                               borderRadius: BorderRadius.circular(10)),
      //                           width: MediaQuery.of(context).size.width * .39,
      //                           height:
      //                               MediaQuery.of(context).size.height * .21,
      //                           child: Column(
      //                             mainAxisAlignment: MainAxisAlignment.center,
      //                             children: <Widget>[
      //                               Container(
      //                                 width: MediaQuery.of(context).size.width *
      //                                     .85,
      //                                 child: Icon(
      //                                   isRewardedAdLoaded == true
      //                                       ? Icons.noise_aware
      //                                       : Icons.download,
      //                                   color: Colors.white,
      //                                   size: 110,
      //                                 ),
      //                               ),
      //                               const SizedBox(
      //                                 height: 10,
      //                               ),
      //                               Flexible(
      //                                 child: isRewardedAdLoaded == true
      //                                     ? const Text(
      //                                         "Watch Ad",
      //                                         style: TextStyle(
      //                                             fontWeight: FontWeight.bold,
      //                                             color: Colors.white,
      //                                             fontSize: 18),
      //                                       )
      //                                     : const Text(
      //                                         "Download Frame",
      //                                         style: TextStyle(
      //                                             fontWeight: FontWeight.bold,
      //                                             color: Colors.white,
      //                                             fontSize: 18),
      //                                       ),
      //                               ),
      //                             ],
      //                           ),
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           );
      //         }));
      //       });
      // } else {
      //   showModalBottomSheet(
      //       context: context,
      //       builder: (context) {
      //         return StatefulBuilder(builder: ((context, setState) {
      //           return Container(
      //             height: 310,
      //             child: Container(
      //               padding: EdgeInsets.only(top: 20),
      //               width: MediaQuery.of(context).size.width * 0.90,
      //               child: Column(
      //                 children: [
      //                   const Text(
      //                     "Choose Your Option",
      //                     style: TextStyle(
      //                         fontWeight: FontWeight.bold, fontSize: 24),
      //                   ),
      //                   const SizedBox(
      //                     height: 20,
      //                   ),
      //                   Row(
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
      //                     children: [
      //                       InkWell(
      //                         onTap: () {
      //                           Navigator.pop(context);
      //                         },
      //                         child: Container(
      //                           decoration: BoxDecoration(
      //                               color: Colors.blue,
      //                               borderRadius: BorderRadius.circular(10)),
      //                           width: MediaQuery.of(context).size.width * .39,
      //                           height:
      //                               MediaQuery.of(context).size.height * .21,
      //                           child: Column(
      //                             mainAxisAlignment: MainAxisAlignment.center,
      //                             children: <Widget>[
      //                               Container(
      //                                 width: MediaQuery.of(context).size.width *
      //                                     .85,
      //                                 child: const Icon(
      //                                   Icons.close,
      //                                   color: Colors.white,
      //                                   size: 110,
      //                                 ),
      //                               ),
      //                               const Text(
      //                                 "May be Later",
      //                                 style: TextStyle(
      //                                     fontWeight: FontWeight.bold,
      //                                     color: Colors.white,
      //                                     fontSize: 18),
      //                               ),
      //                             ],
      //                           ),
      //                         ),
      //                       ),
      //                       InkWell(
      //                         onTap: () async {
      //                           //Navigator.pop(context);
      //                           print("DOWNLOAD and AD");
      //                           print("INDEX VALUE :: $index");
      //
      //                           if(await InternetConnectionChecker().hasConnection){
      //                             downloadSingleFrame(index, imageNames);
      //                           }else{
      //                             Fluttertoast.showToast(msg: "Check internet Connection",backgroundColor: Colors.red);
      //                           }
      //                           // downloadSingleFrame(index, imageNames);
      //
      //                           Navigator.pop(context);
      //                           // Navigator.pop(context);
      //                         },
      //                         child: Container(
      //                           decoration: BoxDecoration(
      //                               color: Colors.blue,
      //                               borderRadius: BorderRadius.circular(10)),
      //                           width: MediaQuery.of(context).size.width * .39,
      //                           height:
      //                               MediaQuery.of(context).size.height * .21,
      //                           child: Column(
      //                             mainAxisAlignment: MainAxisAlignment.center,
      //                             children: <Widget>[
      //                               Container(
      //                                 width: MediaQuery.of(context).size.width *
      //                                     .85,
      //                                 child: Icon(
      //                                   Icons.download,
      //                                   color: Colors.white,
      //                                   size: 110,
      //                                 ),
      //                               ),
      //                               const SizedBox(
      //                                 height: 10,
      //                               ),
      //                               const Flexible(
      //                                 child: Text(
      //                                   "Download Frame",
      //                                   style: TextStyle(
      //                                       fontWeight: FontWeight.bold,
      //                                       color: Colors.white,
      //                                       fontSize: 18),
      //                                 ),
      //                               ),
      //                             ],
      //                           ),
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 ],
      //               ),
      //             ),
      //           );
      //         }));
      //       });
      // }
    } else {
      // downloadSingleFrame(index, imageNames);

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: Container(
                height: 200,
                child: Column(
                  children: [
                    AppBar(
                      title: Text("Download"),
                      backgroundColor: Colors.lightBlue,
                      automaticallyImplyLeading: false,
                    ),
                    Container(
                      height: 15,
                      color: Colors.lightBlue.withOpacity(0.6),
                    ),
                    Container(
                      height: 15,
                      color: Colors.lightBlue.withOpacity(0.4),
                    ),
                    SizedBox(height: 15),
                    Center(
                      child: Text(
                        "Would you like to download frame ? ",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("No")),
                        ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);

                              if (await InternetConnectionChecker()
                                  .hasConnection) {
                                downloadSingleFrame(index, imageNames);
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Check internet Connection",
                                    backgroundColor: Colors.red);
                              }


                            },
                            child: Text("Download")),
                      ],
                    )
                  ],
                ),
              ),
            );
          });

      // showModalBottomSheet(
      //     context: context,
      //     builder: (context) {
      //       return StatefulBuilder(builder: ((context, setState) {
      //         return Container(
      //           height: 310,
      //           child: Container(
      //             padding: EdgeInsets.only(top: 20),
      //             width: MediaQuery.of(context).size.width * 0.90,
      //             child: Column(
      //               children: [
      //                 const Text(
      //                   "Choose Your Option",
      //                   style: TextStyle(
      //                       fontWeight: FontWeight.bold, fontSize: 24),
      //                 ),
      //                 const SizedBox(
      //                   height: 20,
      //                 ),
      //                 Row(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
      //                   children: [
      //                     InkWell(
      //                       onTap: () {
      //                         Navigator.pop(context);
      //                       },
      //                       child: Container(
      //                         decoration: BoxDecoration(
      //                             color: Colors.blue,
      //                             borderRadius: BorderRadius.circular(10)),
      //                         width: MediaQuery.of(context).size.width * .39,
      //                         height: MediaQuery.of(context).size.height * .21,
      //                         child: Column(
      //                           mainAxisAlignment: MainAxisAlignment.center,
      //                           children: <Widget>[
      //                             Container(
      //                               width:
      //                                   MediaQuery.of(context).size.width * .85,
      //                               child: const Icon(
      //                                 Icons.close,
      //                                 color: Colors.white,
      //                                 size: 110,
      //                               ),
      //                             ),
      //                             const Text(
      //                               "May be Later",
      //                               style: TextStyle(
      //                                   fontWeight: FontWeight.bold,
      //                                   color: Colors.white,
      //                                   fontSize: 18),
      //                             ),
      //                           ],
      //                         ),
      //                       ),
      //                     ),
      //                     InkWell(
      //                       onTap: () async {
      //                         //Navigator.pop(context);
      //                         print("DOWNLOAD ONLY");
      //                         // print("INDEX VALUE :: $index");
      //
      //                         if (await InternetConnectionChecker()
      //                             .hasConnection) {
      //                           downloadSingleFrame(index, imageNames);
      //                         } else {
      //                           Fluttertoast.showToast(
      //                               msg: "Check internet Connection",
      //                               backgroundColor: Colors.red);
      //                         }
      //
      //                         Navigator.pop(context);
      //                         // Navigator.pop(context);
      //                       },
      //                       child: Container(
      //                         decoration: BoxDecoration(
      //                             color: Colors.blue,
      //                             borderRadius: BorderRadius.circular(10)),
      //                         width: MediaQuery.of(context).size.width * .39,
      //                         height: MediaQuery.of(context).size.height * .21,
      //                         child: Column(
      //                           mainAxisAlignment: MainAxisAlignment.center,
      //                           children: <Widget>[
      //                             Container(
      //                               width:
      //                                   MediaQuery.of(context).size.width * .85,
      //                               child: Icon(
      //                                 Icons.download,
      //                                 color: Colors.white,
      //                                 size: 110,
      //                               ),
      //                             ),
      //                             const SizedBox(
      //                               height: 10,
      //                             ),
      //                             const Flexible(
      //                               child: Text(
      //                                 "Download Frame",
      //                                 style: TextStyle(
      //                                     fontWeight: FontWeight.bold,
      //                                     color: Colors.white,
      //                                     fontSize: 18),
      //                               ),
      //                             ),
      //                           ],
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ],
      //             ),
      //           ),
      //         );
      //       }));
      //     });
    }
  }

  void downloadSingleFrame(int index, dynamic frameName) async {
    // print("INDEX VALUE :: $index");
    String namePrefix = widget.frameLocationName + "%2F";
    // +
    // widget.framesDetail[index].frameName;
    // print("Location prefix name = "+namePrefix);
    // log(namePrefix);
    setState(() {
      widget.isDownloading[index] = true;
    });
    final dir = await getApplicationDocumentsDirectory();
    // final file = File('${dir.path}/$namePrefix%2F${frameName}');
    final file = File('${dir.path}/$namePrefix${frameName}');

    await FirebaseStorage.instance
        .ref('frames/${widget.frameLocationName}')
        .child(frameName)
        .writeToFile(file);

    widget.framesDetail.removeAt(index);
    widget.framesDetail.insert(index,
        ImgDetails(path: file.path, category: "local", frameName: frameName));
    isRewardedAdLoaded = false;

    setState(() {
      widget.isDownloading[index] = false;
    });
  }

  Future<void> _createRewardedAd() async {
    log("Inside CreateRewarded ad");
    isRewardedAdLoaded = false;
    RewardedAd.loadWithAdManagerAdRequest(
      // adUnitId: AdMobService.rewardedAdUnitId,
      adUnitId: AdMobService.interstitialAdUnitId,
      adManagerRequest: const AdManagerAdRequest(),
      // adManagerAdRequest: AdManagerAdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          isRewardedAdLoaded = true;
          // print('$ad loaded.');
          rewardedAd = ad;
          // _numRewardedLoadAttempts = 0;
          // _showRewardedAd();
        },
        onAdFailedToLoad: (LoadAdError error) {
          // print('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  Future<bool> _showRewardedAd() async {
    if (rewardedAd == null) {
      // print('Warning: attempt to show rewarded before loaded.');
      return await false;
    }
    rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        // print('ad onAdShowedFullScreenContent.');
        // log("1");
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        // print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createRewardedAd();
        // log("2");
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        // print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        // _createRewardedAd();
        // log("3");
      },
      onAdImpression: (RewardedAd ad) => {
        // print('$ad impression occurred.');
      }
    );

    // _rewardedAd!.setImmersiveMode(true);
    rewardedAd!.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      // print("Inside Show Functions");
      // print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });

    return await true;
  }
}
